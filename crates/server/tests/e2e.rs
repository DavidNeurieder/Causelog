//! End-to-end tests: boot the real `causelog` binary on a free port with a
//! temporary database and drive it over HTTP with a cookie jar. This exercises
//! CLI wiring, migrations, the full HTTP surface, and — critically —
//! persistence across process restarts.

use reqwest::StatusCode;
use reqwest::redirect::Policy;
use std::net::TcpListener;
use std::process::Stdio;
use std::time::{Duration, Instant};
use tokio::io::AsyncReadExt;
use tokio::process::{Child, Command};

/// Path to the compiled `causelog` binary, provided by cargo for the package
/// that owns the [[bin]] target.
const BIN: &str = env!("CARGO_BIN_EXE_causelog");

/// Reserve a free localhost port by binding then dropping a listener.
fn free_port() -> u16 {
    let listener = TcpListener::bind("127.0.0.1:0").expect("bind ephemeral port");
    listener.local_addr().unwrap().port()
}

async fn wait_until_healthy(base: &str) {
    let deadline = Instant::now() + Duration::from_secs(30);
    loop {
        if reqwest::get(&format!("{base}/health")).await.is_ok() {
            return;
        }
        assert!(Instant::now() < deadline, "server did not become healthy");
        tokio::time::sleep(Duration::from_millis(200)).await;
    }
}

struct Server {
    child: Child,
    base: String,
}

impl Drop for Server {
    fn drop(&mut self) {
        let _ = self.child.start_kill();
    }
}

async fn spawn_server(db_path: &std::path::Path) -> Server {
    let port = free_port();
    let base = format!("http://127.0.0.1:{port}");
    let child = Command::new(BIN)
        .args([
            "serve",
            "--addr",
            &format!("127.0.0.1:{port}"),
            "--database-url",
            &format!("sqlite://{}", db_path.display()),
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .expect("spawn causelog binary");
    let server = Server {
        child,
        base: base.clone(),
    };
    wait_until_healthy(&base).await;
    server
}

async fn new_client() -> reqwest::Client {
    reqwest::Client::builder()
        .redirect(Policy::none())
        .cookie_store(true)
        .build()
        .expect("build reqwest client")
}

/// `name="csrf_token" value="..."` → token.
fn extract_csrf(html: &str) -> String {
    let marker = r#"name="csrf_token" value=""#;
    let start = html.find(marker).expect("csrf field present") + marker.len();
    let rest = &html[start..];
    let end = rest.find('"').expect("closing quote");
    rest[..end].to_string()
}

/// First `href` starting with `prefix`.
fn extract_href(html: &str, prefix: &str) -> String {
    let marker = format!("href=\"{prefix}");
    let start = html.find(&marker).expect("link present") + marker.len();
    let rest = &html[start..];
    let end = rest.find('"').expect("closing quote");
    format!("{prefix}{}", &rest[..end])
}

async fn post(
    client: &reqwest::Client,
    url: &str,
    fields: &[(&str, &str)],
) -> (StatusCode, Option<String>, String) {
    let res = client.post(url).form(fields).send().await.unwrap();
    let status = res.status();
    let location = res
        .headers()
        .get("location")
        .map(|v| v.to_str().unwrap().to_string());
    let body = res.text().await.unwrap();
    (status, location, body)
}

/// Fresh database file inside a temp dir (kept alive for the whole test).
fn temp_db() -> (tempfile::TempDir, std::path::PathBuf) {
    let dir = tempfile::tempdir().expect("temp dir");
    let db = dir.path().join("causelog.db");
    (dir, db)
}

#[tokio::test]
async fn golden_path_journey_and_persistence() {
    let (_dir, db) = temp_db();
    let server = spawn_server(&db).await;
    let client = new_client().await;

    // Setup (no CSRF required pre-auth).
    let (status, location, _) = post(
        &client,
        &format!("{}/setup", server.base),
        &[
            ("username", "dev"),
            ("display", "Dev"),
            ("password", "longenough1"),
            ("confirm", "longenough1"),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER, "setup redirects");
    assert_eq!(location.as_deref(), Some("/dashboard"));

    // Project.
    let dash = client
        .get(format!("{}/dashboard", server.base))
        .send()
        .await
        .unwrap();
    assert_eq!(dash.status(), StatusCode::OK);
    let dash_html = dash.text().await.unwrap();
    assert!(
        dash_html.contains(r#"name="title" required"#),
        "dashboard exposes a real title field: {dash_html}"
    );
    assert!(
        !dash_html.contains(r#"type="hidden" name="title""#),
        "title must not be a hidden empty input: {dash_html}"
    );
    let csrf = extract_csrf(&dash_html);
    let (status, location, _) = post(
        &client,
        &format!("{}/projects", server.base),
        &[
            ("csrf_token", &csrf),
            ("title", "SQLite + Rust API"),
            ("summary", "Storage for the golden path."),
            ("status", "active"),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);
    let project_url = location
        .as_deref()
        .unwrap()
        .split('?')
        .next()
        .unwrap()
        .to_string();
    assert!(project_url.starts_with("/projects/"));

    let page = client
        .get(format!("{}{project_url}", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(
        body.contains("SQLite + Rust API"),
        "project renders: {body}"
    );
    let csrf = extract_csrf(&body);

    // Decision.
    let (status, _, _) = post(
        &client,
        &format!("{}{project_url}/decisions", server.base),
        &[
            ("csrf_token", &csrf),
            ("title", "Which datastore?"),
            ("context", "Need persistence. Dilithium crystals are out."),
            ("goal_id", ""),
            ("opt_1_label", "SQLite"),
            ("opt_1_pros", "One binary"),
            ("opt_1_cons", "Single writer"),
            ("opt_2_label", ""),
            ("opt_2_pros", ""),
            ("opt_2_cons", ""),
            ("opt_3_label", ""),
            ("opt_3_pros", ""),
            ("opt_3_cons", ""),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);

    let page = client
        .get(format!("{}{project_url}", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    let decision_url = extract_href(&body, "/decisions/");

    // Resolve with a review date.
    let (status, _, _) = post(
        &client,
        &format!("{}{decision_url}/resolve", server.base),
        &[
            ("csrf_token", &csrf),
            ("status", "decided"),
            ("decided_option", "o1"),
            ("rationale", "Single user ⇒ one writer is fine."),
            ("review_at", "2026-12-31"),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);
    let page = client
        .get(format!("{}{decision_url}", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(body.contains("Chose"), "resolution renders: {body}");
    assert!(body.contains("2026-12-31"), "review date renders");

    // Experiment testing the decision → done → capture the lesson as a note.
    let decision_id = decision_url
        .strip_prefix("/decisions/")
        .unwrap()
        .to_string();
    let (status, _, _) = post(
        &client,
        &format!("{}{project_url}/experiments", server.base),
        &[
            ("csrf_token", &csrf),
            ("title", "WAL trial"),
            ("hypothesis", "WAL speeds up reads."),
            ("goal_id", ""),
            ("decision_id", &decision_id),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);
    let page = client
        .get(format!("{}{project_url}", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    let exp_url = extract_href(&body, "/experiments/");

    // Start running, then finish with a result and lesson.
    for (status_field, result_field, lesson_field) in [
        ("ongoing", "", ""),
        ("done", "Reads got 2x faster.", "WAL is worth enabling."),
    ] {
        let (status, _, _) = post(
            &client,
            &format!("{}{exp_url}", server.base),
            &[
                ("csrf_token", &csrf),
                ("title", "WAL trial"),
                ("hypothesis", "WAL speeds up reads."),
                ("status", status_field),
                ("result", result_field),
                ("lesson", lesson_field),
            ],
        )
        .await;
        assert_eq!(status, StatusCode::SEE_OTHER);
    }
    let (status, location, _) = post(
        &client,
        &format!("{}{exp_url}/extract", server.base),
        &[("csrf_token", &csrf)],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);
    let note_url = location
        .as_deref()
        .unwrap()
        .split('?')
        .next()
        .unwrap()
        .to_string();
    let page = client
        .get(format!("{}{note_url}", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(body.contains("Lesson: WAL trial"), "note: {body}");
    assert!(body.contains("WAL is worth enabling."), "lesson captured");

    // Explicit link note → decision.
    let note_id = note_url.strip_prefix("/notes/").unwrap().to_string();
    let (status, _, _) = post(
        &client,
        &format!("{}{project_url}/links", server.base),
        &[
            ("csrf_token", &csrf),
            ("from", &format!("note:{note_id}")),
            ("to", &format!("decision:{decision_id}")),
            ("kind", "supports"),
        ],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);

    // Timeline, graph, and search all reflect the journey.
    let page = client
        .get(format!("{}{project_url}/timeline", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(body.contains("kind-experiment_started"), "timeline: {body}");
    assert!(body.contains("kind-experiment_ended"), "timeline: {body}");
    assert!(body.contains("Completed “WAL trial”"), "timeline: {body}");

    let page = client
        .get(format!("{}{project_url}/graph", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    for marker in [
        "node-note",
        "node-experiment",
        "node-decision",
        "edge-supports",
        "edge-tests",
        "edge-from",
    ] {
        assert!(body.contains(marker), "{marker} missing: {body}");
    }

    let page = client
        .get(format!("{}/search?q=dilithium", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(
        body.contains("Which datastore?"),
        "search finds the decision: {body}"
    );
    assert!(
        body.contains("<mark>Dilithium</mark>"),
        "snippet highlights body matches with original case: {body}"
    );

    // Persistence: kill the process and boot a fresh one on the same DB.
    drop(server);
    let server = spawn_server(&db).await;
    let client = new_client().await;
    let (status, location, _) = post(
        &client,
        &format!("{}/login", server.base),
        &[("username", "dev"), ("password", "longenough1")],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER);
    assert_eq!(location.as_deref(), Some("/dashboard"));
    let dash = client
        .get(format!("{}/dashboard", server.base))
        .send()
        .await
        .unwrap();
    let body = dash.text().await.unwrap();
    assert!(
        body.contains("SQLite + Rust API"),
        "project survived restart: {body}"
    );
}

#[tokio::test]
async fn seed_demo_end_to_end_and_idempotent() {
    let (_dir, db) = temp_db();
    let db_url = format!("sqlite://{}", db.display());

    let run_seed = || async {
        let mut child = Command::new(BIN)
            .args(["seed-demo", "--database-url", &db_url])
            .stdout(Stdio::piped())
            .spawn()
            .expect("spawn seed-demo");
        let mut out = String::new();
        child
            .stdout
            .take()
            .unwrap()
            .read_to_string(&mut out)
            .await
            .unwrap();
        let status = child.wait().await.unwrap();
        (status.success(), out)
    };

    let (ok, out) = run_seed().await;
    assert!(ok, "first seed failed: {out}");
    assert!(out.contains("demo seeded"), "got: {out}");

    // Idempotent: a second run logs that things already exist and succeeds.
    let (ok, out) = run_seed().await;
    assert!(ok, "second seed failed: {out}");
    assert!(
        out.contains("already exists") || out.contains("already seeded"),
        "got: {out}"
    );

    // Boot the server and log in as the seeded demo user.
    let server = spawn_server(&db).await;
    let client = new_client().await;
    let (status, _, body) = post(
        &client,
        &format!("{}/login", server.base),
        &[("username", "demo"), ("password", "demo-password")],
    )
    .await;
    assert_eq!(status, StatusCode::SEE_OTHER, "demo login body: {body}");

    let dash = client
        .get(format!("{}/dashboard", server.base))
        .send()
        .await
        .unwrap();
    let body = dash.text().await.unwrap();
    assert!(
        body.contains("SQLite + Rust API"),
        "seed project on dashboard: {body}"
    );
    assert!(
        body.contains("The Legend of Gloria the Monstera"),
        "funny plant project on dashboard: {body}"
    );
    assert!(
        body.contains("The Coffee Machine Uprising"),
        "funny coffee project on dashboard: {body}"
    );

    // All three seeded projects are listed.
    let page = client
        .get(format!("{}/projects", server.base))
        .send()
        .await
        .unwrap();
    let body = page.text().await.unwrap();
    assert!(body.contains("SQLite + Rust API"), "project listed: {body}");
    assert!(
        body.contains("The Legend of Gloria the Monstera"),
        "gloria listed: {body}"
    );
    assert!(
        body.contains("The Coffee Machine Uprising"),
        "coffee listed: {body}"
    );
}

#[tokio::test]
async fn cli_exposes_subcommands_and_defaults() {
    let help = async {
        let mut child = Command::new(BIN)
            .arg("--help")
            .stdout(Stdio::piped())
            .spawn()
            .expect("spawn --help");
        let mut out = String::new();
        child
            .stdout
            .take()
            .unwrap()
            .read_to_string(&mut out)
            .await
            .unwrap();
        let status = child.wait().await.unwrap();
        assert!(status.success());
        out
    }
    .await;
    assert!(help.contains("serve"), "help must list serve: {help}");
    assert!(
        help.contains("seed-demo"),
        "help must list seed-demo: {help}"
    );

    let serve_help = async {
        let mut child = Command::new(BIN)
            .args(["serve", "--help"])
            .stdout(Stdio::piped())
            .spawn()
            .expect("spawn serve --help");
        let mut out = String::new();
        child
            .stdout
            .take()
            .unwrap()
            .read_to_string(&mut out)
            .await
            .unwrap();
        let status = child.wait().await.unwrap();
        assert!(status.success());
        out
    }
    .await;
    assert!(
        serve_help.contains("--database-url"),
        "must document the URL flag: {serve_help}"
    );
    assert!(
        serve_help.contains("--addr"),
        "must document --addr: {serve_help}"
    );
}
