//! Export integration tests: drive `causelog_export` against a real SQLite
//! repository (and the compiled CLI binary), covering collection, JSON
//! round-trip, and the Markdown/HTML renderer outputs.

use causelog_model::DecisionOption;
use causelog_server::repository::{Repository, SqliteRepository};
use tokio::process::Command;

/// Binary for the CLI smoke test (owned by this package's [[bin]] target).
const BIN: &str = env!("CARGO_BIN_EXE_causelog");

struct Fixture {
    repo: SqliteRepository,
    project_id: uuid::Uuid,
}

async fn seed(db_url: &str) -> Fixture {
    let repo = SqliteRepository::connect(db_url).await.unwrap();
    repo.migrate().await.unwrap();

    let project = repo
        .create_project("Export Fiesta", "Proving exports work.", "active", None)
        .await
        .unwrap();
    let goal = repo
        .create_goal(project.id, "Aim high", "Body **bold**.", None, None)
        .await
        .unwrap();

    let decision = repo
        .create_decision(
            project.id,
            Some(goal.id),
            "Pick a database",
            "We outgrew the CSV file.",
            &[
                DecisionOption {
                    id: "sqlite".into(),
                    label: "SQLite".into(),
                    pros: "Zero ops.".into(),
                    cons: "Not distributed.".into(),
                },
                DecisionOption {
                    id: "postgres".into(),
                    label: "Postgres".into(),
                    pros: "Real database.".into(),
                    cons: "Cats to herd.".into(),
                },
            ],
            None,
        )
        .await
        .unwrap();
    repo.resolve_decision(
        decision.id,
        "decided".into(),
        Some("sqlite".into()),
        "We like boring.",
        None,
    )
    .await
    .unwrap();

    let experiment = repo
        .create_experiment(
            project.id,
            Some(goal.id),
            Some(decision.id),
            "Volume probe",
            "Does it survive a billion rows?",
            None,
        )
        .await
        .unwrap();
    repo.update_experiment(
        experiment.id,
        "Volume probe",
        "Does it survive a billion rows?",
        "done".into(),
        "Survived.",
        "Lesson: measure first.",
    )
    .await
    .unwrap();
    repo.create_event(
        experiment.id,
        "measurement".into(),
        1_700_000_000_000,
        "1B rows in 42s.",
    )
    .await
    .unwrap();

    repo.create_note(
        project.id,
        "Gotchas",
        "Watch out for WAL.",
        Some("decision"),
        Some(decision.id),
        None,
    )
    .await
    .unwrap();
    repo.create_link(
        project.id,
        "experiment".into(),
        experiment.id,
        "decision".into(),
        decision.id,
        "supports".into(),
    )
    .await
    .unwrap();

    Fixture {
        repo,
        project_id: project.id,
    }
}

async fn collect_fixture(dir: &std::path::Path) -> (Fixture, causelog_export::ExportProject) {
    let db = dir.join("test.db");
    let fixture = seed(&format!("sqlite://{}", db.display())).await;
    let export = causelog_export::collect(&fixture.repo, fixture.project_id)
        .await
        .expect("collect should succeed");
    (fixture, export)
}

#[tokio::test]
async fn collection_builds_complete_project() {
    let dir = tempfile::tempdir().unwrap();
    let (fixture, export) = collect_fixture(dir.path()).await;
    let _ = &fixture.repo;

    assert_eq!(export.format, "causelog-export");
    assert_eq!(export.version, 1);
    assert_eq!(export.project.title, "Export Fiesta");
    assert_eq!(export.project.summary, "Proving exports work.");
    assert_eq!(export.goals.len(), 1);
    assert_eq!(export.decisions.len(), 1);
    assert_eq!(export.experiments.len(), 1);
    assert_eq!(export.notes.len(), 1);
    assert_eq!(export.links.len(), 1);
    assert_eq!(
        export.revisions.len(),
        3,
        "decision create+resolve and note each snapshot a revision"
    );
    assert_eq!(export.events.len(), 1, "experiment events are collected");
    assert_eq!(
        export.decisions[0].state.as_deref(),
        Some("validated"),
        "a done experiment with a lesson validates the decision"
    );
    assert_eq!(
        export.decisions[0].decided_option.as_deref(),
        Some("sqlite")
    );
    assert_eq!(export.decisions[0].options[0].label, "SQLite");
}

#[tokio::test]
async fn markdown_export_writes_every_entity() {
    let dir = tempfile::tempdir().unwrap();
    let (_, export) = collect_fixture(dir.path()).await;

    let files = causelog_export::markdown::render_markdown(&export);
    let names: Vec<&str> = files.iter().map(|f| f.path.as_str()).collect();
    assert!(names.contains(&"README.md"));
    assert!(names.contains(&"timeline.md"));
    assert!(names.contains(&"relationships.md"));
    assert!(names.iter().any(|p| p.starts_with("goals/aim-high-")));
    assert!(
        names
            .iter()
            .any(|p| p.starts_with("decisions/pick-a-database-"))
    );
    assert!(
        names
            .iter()
            .any(|p| p.starts_with("experiments/volume-probe-"))
    );
    assert!(names.iter().any(|p| p.starts_with("notes/gotchas-")));

    let rel = files.iter().find(|f| f.path == "relationships.md").unwrap();
    assert!(rel.content.contains("--supports-->"));
}

#[tokio::test]
async fn html_export_renders_states_and_story() {
    let dir = tempfile::tempdir().unwrap();
    let (_, export) = collect_fixture(dir.path()).await;

    let files = causelog_export::html::render_html(&export);
    let index = files.iter().find(|f| f.path == "index.html").unwrap();
    assert!(index.content.contains("<title>Export Fiesta</title>"));
    assert!(index.content.contains("state-validated"));
    assert!(index.content.contains("story-decision"));
    assert!(index.content.contains("Pick a database"));
    assert!(files.iter().any(|f| f.path == "assets/styles.css"));
}

/// `causelog export <title> --format json --output out.json` produces a
/// parseable versioned envelope.
#[tokio::test]
async fn cli_exports_json() {
    let dir = tempfile::tempdir().unwrap();
    let db = dir.path().join("test.db");
    let out = dir.path().join("out.json");
    seed(&format!("sqlite://{}", db.display())).await;

    let status = Command::new(BIN)
        .arg("export")
        .arg("Export Fiesta")
        .arg("--database-url")
        .arg(format!("sqlite://{}", db.display()))
        .arg("--format")
        .arg("json")
        .arg("--output")
        .arg(out.to_str().unwrap())
        .status()
        .await
        .unwrap();
    assert!(status.success(), "CLI export must succeed");

    let raw = std::fs::read_to_string(&out).unwrap();
    let parsed: causelog_export::ExportProject = serde_json::from_str(&raw).unwrap();
    assert_eq!(parsed.format, "causelog-export");
    assert_eq!(parsed.version, 1);
    assert_eq!(parsed.project.title, "Export Fiesta");
}

/// `causelog export <id>` also works, and an unknown title fails cleanly.
#[tokio::test]
async fn cli_resolves_by_id_and_rejects_unknown() {
    let dir = tempfile::tempdir().unwrap();
    let db = dir.path().join("test.db");
    let fixture = seed(&format!("sqlite://{}", db.display())).await;

    let status = Command::new(BIN)
        .arg("export")
        .arg(fixture.project_id.to_string())
        .arg("--database-url")
        .arg(format!("sqlite://{}", db.display()))
        .arg("--format")
        .arg("json")
        .status()
        .await
        .unwrap();
    assert!(status.success(), "id resolution must succeed");

    let status = Command::new(BIN)
        .arg("export")
        .arg("no such project")
        .arg("--database-url")
        .arg(format!("sqlite://{}", db.display()))
        .status()
        .await
        .unwrap();
    assert!(!status.success(), "unknown titles must fail");
}
