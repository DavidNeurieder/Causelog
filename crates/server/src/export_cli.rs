//! `causelog export project <ref> --format json|markdown|html|archive` —
//! export one project from a local database. No sessions here: this is the
//! self-hosted, single-admin CLI, so any resolvable project can be exported.

use std::fs;
use std::path::PathBuf;

use causelog_content::now_ms;
use causelog_export::ExportFormat;
use causelog_export::archive::archive;
use causelog_export::build_presentation;
use causelog_export::collect;
use causelog_export::html::render_html;
use causelog_export::json::render_json;
use causelog_export::markdown::render_markdown;
use causelog_export::model::file_stem;
use causelog_export::odp::render_odp;
use causelog_export::resolve_project;
use causelog_export::story::build_story;
use causelog_server::repository::SqliteRepository;
use clap::Args;

#[derive(Args)]
pub struct ExportArgs {
    /// SQLite database URL or file path.
    #[arg(long, env = "DATABASE_URL", default_value = "sqlite://causelog.db")]
    pub database_url: String,

    /// Output format.
    #[arg(long, value_enum)]
    pub format: Option<ExportFormat>,

    /// Output path. JSON/Archive: a single file (stdout when omitted, for
    /// JSON only). Markdown/HTML: the directory to write into (defaults to
    /// `./<project>-export`).
    #[arg(long)]
    pub output: Option<PathBuf>,

    /// Project reference: a project id (UUID) or an exact title.
    pub project: String,
}

pub async fn run(args: &ExportArgs) -> anyhow::Result<()> {
    let repo = SqliteRepository::connect(&args.database_url).await?;
    repo.migrate().await?;
    let repo = std::sync::Arc::new(repo);

    let project = resolve_project(repo.as_ref(), &args.project).await?;
    let export = collect(repo.as_ref(), project.id).await?;

    let format = args.format.unwrap_or(ExportFormat::Json);
    match format {
        ExportFormat::Json => write_json(&export, args.output.as_deref()).await?,
        ExportFormat::Markdown => {
            let dir = args.output.clone().unwrap_or_else(|| default_dir(&export));
            write_tree(&dir, &render_markdown(&export)).await?;
            tracing::info!(dir = %dir.display(), "markdown export written");
        }
        ExportFormat::Html => {
            let dir = args.output.clone().unwrap_or_else(|| default_dir(&export));
            write_tree(&dir, &render_html(&export)).await?;
            tracing::info!(dir = %dir.display(), "html export written");
        }
        ExportFormat::Archive => {
            let path = args
                .output
                .clone()
                .unwrap_or_else(|| default_dir(&export).with_extension("zip"));
            let bytes = archive(&export, &render_markdown(&export), &render_html(&export));
            fs::write(&path, bytes)?;
            tracing::info!(path = %path.display(), "archive export written");
        }
        ExportFormat::Odp => {
            let path = args
                .output
                .clone()
                .unwrap_or_else(|| default_dir(&export).with_extension("odp"));
            let story = build_story(&export);
            let presentation = build_presentation(&story);
            let bytes = render_odp(&presentation, &export.causelog_version);
            fs::write(&path, bytes)?;
            tracing::info!(path = %path.display(), "odp export written");
        }
    }
    Ok(())
}

async fn write_json(
    export: &causelog_export::model::ExportProject,
    output: Option<&std::path::Path>,
) -> anyhow::Result<()> {
    let json = render_json(export)?;
    match output {
        Some(path) => {
            fs::write(path, json)?;
            tracing::info!(path = %path.display(), "json export written");
        }
        None => print!("{json}"),
    }
    Ok(())
}

/// Default export directory: `./<project-slug>-export`, timestamped so
/// repeated exports do not clobber each other silently.
fn default_dir(export: &causelog_export::model::ExportProject) -> PathBuf {
    let slug = file_stem(&export.project.title, export.project.id);
    let stamp = now_ms() / 1000;
    PathBuf::from(format!("{slug}-{stamp}-export"))
}

async fn write_tree(
    root: &std::path::Path,
    files: &[causelog_export::ExportFile],
) -> anyhow::Result<()> {
    fs::create_dir_all(root)?;
    for file in files {
        let path = root.join(&file.path);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?;
        }
        fs::write(&path, &file.content)?;
    }
    Ok(())
}
