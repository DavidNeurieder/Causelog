//! Kaizen CLI entrypoint. Solo mode: single binary + embedded SQLite.
//!
//! `serve` runs plain HTTP, or HTTPS with a certificate you supply
//! (`--tls-cert`/`--tls-key`) or with automatic Let's Encrypt issuance
//! (`--tls-domain`). When TLS is active an HTTP redirect listener starts on
//! port 80 unless `--no-http-redirect` is given.
//!
//! `seed-demo` creates a first user and a demo project so you can poke around
//! before using the app for real.

use std::path::{Path, PathBuf};
use std::time::Duration;

use axum::{
    Router,
    http::{StatusCode, Uri, header},
};
use axum_server::tls_rustls::RustlsConfig;
use clap::{Args, Parser, Subcommand};
use kaizen_model::DecisionOption;
use kaizen_server::auth;
use kaizen_server::repository::{Repository as _, SqliteRepository, repo_box};
use rustls_acme::AcmeConfig;
use rustls_acme::caches::DirCache;
use tokio::net::TcpListener;
use tokio::sync::watch;
use tracing_subscriber::EnvFilter;

#[derive(Parser)]
#[command(
    name = "kaizen",
    version,
    about = "Self-hosted engineering knowledge system"
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,
}

#[derive(Subcommand)]
enum Command {
    /// Start the Kaizen server (default).
    Serve(ServeArgs),
    /// Create a first user and a demo project, then exit.
    SeedDemo {
        /// SQLite database URL or file path.
        #[arg(long, env = "DATABASE_URL", default_value = "sqlite://kaizen.db")]
        database_url: String,
    },
}

#[derive(Args)]
struct ServeArgs {
    /// SQLite database URL or file path.
    #[arg(long, env = "DATABASE_URL", default_value = "sqlite://kaizen.db")]
    database_url: String,
    /// Address to bind (plain HTTP by default, TLS when --tls-* is given).
    #[arg(long, env = "KAIZEN_ADDR", default_value = "127.0.0.1:8080")]
    addr: String,
    /// Automate HTTPS via Let's Encrypt (TLS-ALPN-01). Takes precedence over
    /// --tls-cert/--tls-key.
    #[arg(long, env = "KAIZEN_TLS_DOMAIN")]
    tls_domain: Option<String>,
    /// Path to a TLS certificate chain (PEM), bring-your-own HTTPS.
    #[arg(long, env = "KAIZEN_TLS_CERT")]
    tls_cert: Option<PathBuf>,
    /// Path to the matching TLS private key (PEM).
    #[arg(long, env = "KAIZEN_TLS_KEY")]
    tls_key: Option<PathBuf>,
    /// Directory for the Let's Encrypt ACME cache.
    #[arg(long, env = "KAIZEN_TLS_CACHE_DIR", default_value = "./tls")]
    tls_cache_dir: PathBuf,
    /// Do not start the HTTP→HTTPS redirect listener when TLS is active.
    #[arg(long)]
    no_http_redirect: bool,
    /// Port for the HTTP→HTTPS redirect listener (default 80).
    #[arg(long, env = "KAIZEN_HTTP_REDIRECT_PORT", default_value_t = 80)]
    http_redirect_port: u16,
}

impl Default for ServeArgs {
    fn default() -> Self {
        Self {
            database_url: "sqlite://kaizen.db".into(),
            addr: "127.0.0.1:8080".into(),
            tls_domain: None,
            tls_cert: None,
            tls_key: None,
            tls_cache_dir: "./tls".into(),
            no_http_redirect: false,
            http_redirect_port: 80,
        }
    }
}

enum TlsMode {
    None,
    Byo { cert: PathBuf, key: PathBuf },
    Acme { domain: String },
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    match cli.command {
        Some(Command::SeedDemo { database_url }) => seed_demo(&database_url).await,
        Some(Command::Serve(args)) => serve(args).await,
        None => serve(ServeArgs::default()).await,
    }
}

/// First-run friendliness: create a demo user (if none exists) and a small
/// project showing the whole golden path — goal → decision → experiment →
/// note, with a link between them.
async fn seed_demo(database_url: &str) -> anyhow::Result<()> {
    let repo = SqliteRepository::connect(database_url).await?;
    repo.migrate().await?;

    let (username, password) = ("demo", "demo-password");
    if repo.find_user_by_username(username).await?.is_none() {
        let hash = auth::hash_password(password)
            .map_err(|e| anyhow::anyhow!("failed to hash password: {e:?}"))?;
        repo.create_first_user(username, "Demo", &hash).await?;
        tracing::info!("created demo user '{username}' (password '{password}')");
    } else {
        tracing::info!("demo user already exists");
    }

    // Skip if a demo project already exists.
    let projects = repo.list_projects().await?;
    if projects.iter().any(|p| p.title == "SQLite + Rust API") {
        tracing::info!("demo project already seeded");
        return Ok(());
    }

    let project = repo
        .create_project(
            "SQLite + Rust API",
            "A worked example: choosing a datastore for a small self-hosted service.",
            "active",
        )
        .await?;
    let goal = repo
        .create_goal(
            project.id,
            "Ship the MVP with the least operational surface",
            "One machine, one binary, no external services.",
        )
        .await?;

    let decision = repo
        .create_decision(
            project.id,
            Some(goal.id),
            "Which datastore?",
            "The API keeps one user's history; writes are rare and local.",
            &[
                DecisionOption {
                    id: "o1".into(),
                    label: "SQLite".into(),
                    pros: "Zero ops, single file, transactional, fast enough for one writer."
                        .into(),
                    cons: "Single-writer semantics.".into(),
                },
                DecisionOption {
                    id: "o2".into(),
                    label: "Postgres".into(),
                    pros: "Concurrent writers, familiar ops.".into(),
                    cons: "A whole server to run and back up.".into(),
                },
            ],
        )
        .await?;
    repo.resolve_decision(
        decision.id,
        "decided",
        Some("o1".into()),
        "One writer is the actual load; SQLite removes the operational surface.",
        None,
    )
    .await?;

    let experiment = repo
        .create_experiment(
            project.id,
            Some(goal.id),
            Some(decision.id),
            "WAL for six weeks",
            "WAL mode keeps reads fast while a single writer applies changes.",
        )
        .await?;
    repo.update_experiment(
        experiment.id,
        "WAL for six weeks",
        "WAL mode keeps reads fast while a single writer applies changes.",
        "done",
        "Reads stayed responsive and no locking incidents occurred.",
        "SQLite WAL is a free win for single-writer workloads.",
    )
    .await?;

    let note = repo
        .create_note(
            project.id,
            &format!("Lesson: {}", experiment.title),
            "SQLite WAL is a free win for single-writer workloads. Re-evaluate if a second writer ever appears.",
            Some("experiment"),
            Some(experiment.id),
        )
        .await?;
    repo.create_link(
        project.id,
        "note",
        note.id,
        "decision",
        decision.id,
        "supports",
    )
    .await?;

    tracing::info!("demo project seeded — log in at /login with '{username}' / '{password}'");
    Ok(())
}

async fn serve(args: ServeArgs) -> anyhow::Result<()> {
    // rustls needs a crypto provider installed exactly once, before any
    // `ServerConfig` is built.
    rustls::crypto::aws_lc_rs::default_provider()
        .install_default()
        .ok();

    let repo = SqliteRepository::connect(&args.database_url).await?;
    repo.migrate().await?;
    tracing::info!(database_url = %args.database_url, "database ready");

    let mode = tls_mode(&args)?;
    let app = kaizen_server::app_secure(repo_box(repo));
    let socket_addr: std::net::SocketAddr = args.addr.parse()?;

    let (shutdown_tx, mut shutdown_rx) = watch::channel(false);
    spawn_shutdown_signal(shutdown_tx);

    match mode {
        TlsMode::None => {
            let listener = TcpListener::bind(socket_addr).await?;
            tracing::info!(addr = %args.addr, "Kaizen listening (http)");
            axum::serve(listener, app)
                .with_graceful_shutdown(async move {
                    shutdown_rx.changed().await.ok();
                })
                .await?;
        }
        TlsMode::Byo { cert, key } => {
            let config = RustlsConfig::from_pem_file(&cert, &key).await?;
            tracing::info!(
                addr = %args.addr,
                cert = %cert.display(),
                "Kaizen listening (https, custom certificate)"
            );
            if !args.no_http_redirect {
                spawn_redirect_listener(
                    redirect_host(&args),
                    args.http_redirect_port,
                    socket_addr.port(),
                    shutdown_rx.clone(),
                );
            }
            spawn_cert_reloader(config.clone(), cert, key);
            let handle = axum_server::Handle::new();
            spawn_handle_shutdown(shutdown_rx, handle.clone());
            axum_server::bind_rustls(socket_addr, config.clone())
                .handle(handle)
                .serve(app.into_make_service())
                .await?;
        }
        TlsMode::Acme { domain } => {
            let mut state = AcmeConfig::new([domain.clone()])
                .cache_option(Some(DirCache::new(args.tls_cache_dir.clone())))
                .directory_lets_encrypt(true)
                .state();
            let acceptor = state.axum_acceptor(state.default_rustls_config());
            tokio::spawn(async move {
                use futures::StreamExt;
                loop {
                    match state.next().await {
                        Some(Ok(event)) => tracing::info!(?event, "acme event"),
                        Some(Err(err)) => tracing::error!(?err, "acme error"),
                        None => break,
                    }
                }
            });
            tracing::info!(
                addr = %args.addr,
                domain = %domain,
                "Kaizen listening (https, automatic Let's Encrypt)"
            );
            if !args.no_http_redirect {
                spawn_redirect_listener(
                    domain.clone(),
                    args.http_redirect_port,
                    socket_addr.port(),
                    shutdown_rx.clone(),
                );
            }
            let handle = axum_server::Handle::new();
            spawn_handle_shutdown(shutdown_rx, handle.clone());
            axum_server::bind(socket_addr)
                .handle(handle)
                .acceptor(acceptor)
                .serve(app.into_make_service())
                .await?;
        }
    }
    Ok(())
}

/// Resolve the TLS mode with the documented precedence:
/// `--tls-domain` > `--tls-cert`/`--tls-key` > plain HTTP.
fn tls_mode(args: &ServeArgs) -> anyhow::Result<TlsMode> {
    if let Some(domain) = &args.tls_domain {
        return Ok(TlsMode::Acme {
            domain: domain.clone(),
        });
    }
    match (&args.tls_cert, &args.tls_key) {
        (Some(cert), Some(key)) => Ok(TlsMode::Byo {
            cert: cert.clone(),
            key: key.clone(),
        }),
        (None, None) => Ok(TlsMode::None),
        _ => anyhow::bail!("--tls-cert and --tls-key must be provided together"),
    }
}

/// Host that HTTPS redirects should point at: the configured domain in ACME
/// mode, otherwise the host part of `--addr`.
fn redirect_host(args: &ServeArgs) -> String {
    if let Some(domain) = &args.tls_domain {
        return domain.clone();
    }
    args.addr
        .rsplit_once(':')
        .map(|(host, _)| host)
        .unwrap_or(&args.addr)
        .to_string()
}

/// 301 every request to the matching `https://` URL.
fn http_redirect_app(host: String, tls_port: u16) -> Router {
    Router::new().fallback(move |uri: Uri| {
        let target = format!(
            "https://{host}:{tls_port}{path}",
            path = uri.path_and_query().map(|p| p.as_str()).unwrap_or("/")
        );
        async move {
            (
                StatusCode::MOVED_PERMANENTLY,
                [(header::LOCATION, target)],
                "Redirecting to HTTPS".to_string(),
            )
        }
    })
}

fn spawn_redirect_listener(
    host: String,
    port: u16,
    tls_port: u16,
    mut shutdown_rx: watch::Receiver<bool>,
) {
    tokio::spawn(async move {
        let listener = match TcpListener::bind(format!("0.0.0.0:{port}")).await {
            Ok(l) => l,
            Err(err) => {
                tracing::warn!(port, error = %err, "HTTP→HTTPS redirect listener not started");
                return;
            }
        };
        tracing::info!(port, "HTTP→HTTPS redirect listening");
        let app = http_redirect_app(host, tls_port);
        if let Err(err) = axum::serve(listener, app)
            .with_graceful_shutdown(async move {
                shutdown_rx.changed().await.ok();
            })
            .await
        {
            tracing::warn!(error = %err, "HTTP→HTTPS redirect listener stopped");
        }
    });
}

/// Watch the shutdown channel and drain axum-server's connections.
fn spawn_handle_shutdown(
    mut shutdown_rx: watch::Receiver<bool>,
    handle: axum_server::Handle<std::net::SocketAddr>,
) {
    tokio::spawn(async move {
        shutdown_rx.changed().await.ok();
        handle.shutdown();
    });
}

fn spawn_shutdown_signal(tx: watch::Sender<bool>) {
    tokio::spawn(async move {
        let _ = tokio::signal::ctrl_c().await;
        let _ = tx.send(true);
    });
}

/// Reload the TLS certificate/key whenever either file changes on disk
/// (e.g. after a renewal). Checks mtimes every 30 s.
fn spawn_cert_reloader(config: RustlsConfig, cert: PathBuf, key: PathBuf) {
    tokio::spawn(async move {
        let mut ticker = tokio::time::interval(Duration::from_secs(30));
        ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
        let mut last = file_mtimes(&cert, &key);
        loop {
            ticker.tick().await;
            let now = file_mtimes(&cert, &key);
            if now == last {
                continue;
            }
            last = now;
            match config.reload_from_pem_file(&cert, &key).await {
                Ok(()) => tracing::info!("TLS certificate reloaded"),
                Err(err) => tracing::error!(error = %err, "TLS certificate reload failed"),
            }
        }
    });
}

fn file_mtimes(
    cert: &Path,
    key: &Path,
) -> (Option<std::time::SystemTime>, Option<std::time::SystemTime>) {
    let mtime = |p: &Path| std::fs::metadata(p).ok().and_then(|m| m.modified().ok());
    (mtime(cert), mtime(key))
}
