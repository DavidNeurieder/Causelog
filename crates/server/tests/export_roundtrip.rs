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
        "decided",
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
        "done",
        "Survived.",
        "Lesson: measure first.",
    )
    .await
    .unwrap();
    repo.create_event(
        experiment.id,
        "measurement",
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
        "experiment",
        experiment.id,
        "decision",
        decision.id,
        "supports",
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

/// Plan §2b: a synthetic project with many decisions/notes/experiments must
/// collect into one logically-consistent snapshot with every revision attached
/// to the right entity. Collection is project-level (the repository calls
/// `list_revisions_for_project`/`list_events_for_project`), so this exercise
/// is O(1) database round-trips regardless of entity count.
#[tokio::test]
async fn large_snapshot_attaches_every_revision_and_event() {
    let dir = tempfile::tempdir().unwrap();
    let db = dir.path().join("big.db");
    let fixture = seed(&format!("sqlite://{}", db.display())).await;
    let repo = &fixture.repo;
    let pid = fixture.project_id;

    const N: usize = 40;
    let base = 1; // `seed` already created one decision (and one experiment/note).
    let goal = repo.list_goals(pid).await.unwrap().remove(0);
    for i in 0..N {
        let title = format!("decision {i}");
        let ctx = format!("ctx {i}");
        let d = repo
            .create_decision(pid, Some(goal.id), &title, &ctx, &[], None)
            .await
            .unwrap();
        let rationale = format!("chose {i}");
        repo.resolve_decision(d.id, "decided", None, &rationale, None)
            .await
            .unwrap();
        let body_a = format!("thought {i} a");
        let body_b = format!("thought {i} b");
        repo.create_note(pid, "Gotchas", &body_a, Some("decision"), Some(d.id), None)
            .await
            .unwrap();
        repo.create_note(pid, "Gotchas", &body_b, Some("decision"), Some(d.id), None)
            .await
            .unwrap();

        let etitle = format!("exp {i}");
        let ehyp = format!("hyp {i}");
        let e = repo
            .create_experiment(pid, Some(goal.id), Some(d.id), &etitle, &ehyp, None)
            .await
            .unwrap();
        let ev_a = format!("m {i} a");
        let ev_b = format!("m {i} b");
        repo.create_event(e.id, "measurement", 1_800_000_000_000, &ev_a)
            .await
            .unwrap();
        repo.create_event(e.id, "measurement", 1_800_000_000_001, &ev_b)
            .await
            .unwrap();
    }

    let snapshot = repo.collect_project_snapshot(pid).await.unwrap();
    assert_eq!(
        snapshot.decisions.len(),
        N + base,
        "every decision collected"
    );
    assert_eq!(
        snapshot.experiments.len(),
        N + base,
        "every experiment collected"
    );
    assert_eq!(
        snapshot.notes.len(),
        2 * N + 1,
        "every note collected (seed has one)"
    );
    assert_eq!(
        snapshot.revisions.len(),
        4 * N + 3,
        "create+resolve+2 notes per decision, plus the seed's 3 revisions"
    );
    assert_eq!(
        snapshot.events.len(),
        2 * N + 1,
        "two events per experiment, plus the seed's event"
    );

    // Attachments are correct: each loop-created decision carries exactly the
    // two decision revisions (create + resolve); its two notes snapshot under
    // their own note entity ids. The seed decision has two as well. Events
    // snap to their experiment.
    for d in &snapshot.decisions {
        let revs = snapshot
            .revisions
            .iter()
            .filter(|r| r.entity_id == d.id)
            .count();
        assert_eq!(revs, 2, "create+resolve attached to {}", d.title);
    }
    for e in &snapshot.experiments {
        let expected = if e.title == "Volume probe" { 1 } else { 2 };
        let evs = snapshot
            .events
            .iter()
            .filter(|ev| ev.experiment_id == e.id)
            .count();
        assert_eq!(evs, expected, "events attached to {}", e.title);
    }

    let story = story(&snapshot);
    assert_eq!(story.key_decisions.len(), N + base);
    assert_eq!(
        story.current_state.len(),
        N + base,
        "all decided decisions are current"
    );
}

/// Default-configured story for the given project snapshot.
fn story(export: &causelog_export::model::ExportProject) -> causelog_export::story::ProjectStory {
    causelog_export::story_config::build_story_with_config(export, None)
}

#[tokio::test]
async fn markdown_export_writes_every_entity() {
    let dir = tempfile::tempdir().unwrap();
    let (_, export) = collect_fixture(dir.path()).await;

    let files = causelog_export::markdown::render_markdown(&export, &story(&export));
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

    let files = causelog_export::html::render_html(&export, &story(&export));
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

/// The CLI consumes the saved `StoryConfig` exactly like the web and the
/// library renderers: the compiled `causelog export` command must not
/// resurrect hidden content or ignore the saved ordering.
#[tokio::test]
async fn cli_exports_honor_the_saved_story_config() {
    use causelog_export::story_config::build_story_with_config;

    let dir = tempfile::tempdir().unwrap();
    let db = dir.path().join("cli.db");
    let url = format!("sqlite://{}", db.display());
    let (fixture, config) = rich_seed_configured(&url).await;
    fixture
        .repo
        .set_story_config(fixture.project_id, &serde_json::to_string(&config).unwrap())
        .await
        .unwrap();

    let snapshot = fixture
        .repo
        .collect_project_snapshot(fixture.project_id)
        .await
        .unwrap();
    let story = build_story_with_config(&snapshot, Some(&config));
    let chain: Vec<(String, String)> = causelog_export::story_chain(&story)
        .into_iter()
        .map(|e| (e.kind.to_string(), e.title.clone()))
        .collect();
    let decision_titles: Vec<String> = story
        .key_decisions
        .iter()
        .map(|d| d.title.clone())
        .collect();
    let experiment_titles: Vec<String> =
        story.experiments.iter().map(|e| e.title.clone()).collect();

    let md_dir = dir.path().join("md");
    let status = Command::new(BIN)
        .arg("export")
        .arg(fixture.project_id.to_string())
        .arg("--database-url")
        .arg(&url)
        .arg("--format")
        .arg("markdown")
        .arg("--output")
        .arg(md_dir.to_str().unwrap())
        .status()
        .await
        .unwrap();
    assert!(status.success(), "CLI markdown export must succeed");
    let readme = std::fs::read_to_string(md_dir.join("README.md")).unwrap();
    assert_eq!(md_chain(&readme), chain, "CLI markdown story != canonical");
    assert!(
        !md_chain(&readme)
            .iter()
            .any(|(_, t)| t == "Pick a database"),
        "CLI markdown resurrected the hidden decision"
    );
    assert!(readme.contains("The real bottleneck is waking up."));

    let html_dir = dir.path().join("html");
    let status = Command::new(BIN)
        .arg("export")
        .arg(fixture.project_id.to_string())
        .arg("--database-url")
        .arg(&url)
        .arg("--format")
        .arg("html")
        .arg("--output")
        .arg(html_dir.to_str().unwrap())
        .status()
        .await
        .unwrap();
    assert!(status.success(), "CLI html export must succeed");
    let index = std::fs::read_to_string(html_dir.join("index.html")).unwrap();
    assert_eq!(html_chain(&index), chain, "CLI html story != canonical");

    let odp_path = dir.path().join("cli.odp");
    let status = Command::new(BIN)
        .arg("export")
        .arg(fixture.project_id.to_string())
        .arg("--database-url")
        .arg(&url)
        .arg("--format")
        .arg("odp")
        .arg("--output")
        .arg(odp_path.to_str().unwrap())
        .status()
        .await
        .unwrap();
    assert!(status.success(), "CLI odp export must succeed");
    let bytes = std::fs::read(odp_path).unwrap();
    let mut content = String::new();
    {
        let mut zip = zip::ZipArchive::new(std::io::Cursor::new(&bytes[..])).unwrap();
        use std::io::Read;
        let mut entry = zip.by_name("content.xml").unwrap();
        entry.read_to_string(&mut content).unwrap();
    }
    let titles = odp_titles(&content);
    let shown_decisions: Vec<&String> = titles
        .iter()
        .filter(|t| decision_titles.contains(t))
        .collect();
    assert_eq!(
        shown_decisions,
        decision_titles.iter().collect::<Vec<_>>(),
        "CLI odp decision order"
    );
    let shown_experiments: Vec<&String> = titles
        .iter()
        .filter(|t| experiment_titles.contains(t))
        .collect();
    assert_eq!(
        shown_experiments,
        experiment_titles.iter().collect::<Vec<_>>(),
        "CLI odp experiment order"
    );

    let archive_path = dir.path().join("cli.zip");
    let status = Command::new(BIN)
        .arg("export")
        .arg(fixture.project_id.to_string())
        .arg("--database-url")
        .arg(&url)
        .arg("--format")
        .arg("archive")
        .arg("--output")
        .arg(archive_path.to_str().unwrap())
        .status()
        .await
        .unwrap();
    assert!(status.success(), "CLI archive export must succeed");
    let bytes = std::fs::read(archive_path).unwrap();
    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(&bytes[..])).unwrap();
    let mut readme = String::new();
    {
        use std::io::Read;
        let mut entry = archive.by_name("README.md").unwrap();
        entry.read_to_string(&mut readme).unwrap();
    }
    assert_eq!(
        md_chain(&readme),
        chain,
        "CLI archive markdown story != canonical"
    );
}

/// Extract the ordered `- `kind` **title**` story-chain bullets from a README.
fn md_chain(readme: &str) -> Vec<(String, String)> {
    let mut out = Vec::new();
    for line in readme.lines() {
        let Some(rest) = line.strip_prefix("- `") else {
            continue;
        };
        let Some((kind, rest)) = rest.split_once('`') else {
            continue;
        };
        let Some(title) = rest.trim_start().strip_prefix("**") else {
            continue;
        };
        let title = title.split("**").next().unwrap_or("").to_string();
        out.push((kind.to_string(), title));
    }
    out
}

/// Extract the ordered `<li class="story-{kind}">` entries from index.html.
fn html_chain(index: &str) -> Vec<(String, String)> {
    let mut out = Vec::new();
    // The first split chunk is everything before the first story `<li>`; each
    // later chunk starts right after a `story-` prefix.
    for chunk in index.split("<li class=\"story-").skip(1) {
        let Some(kind) = chunk.split('"').next() else {
            continue;
        };
        let Some(anchor) = chunk.find("<a href=") else {
            continue;
        };
        let anchor = &chunk[anchor..];
        let Some(rest) = anchor.split_once('>') else {
            continue;
        };
        let title = rest.1.split("</a>").next().unwrap_or("").to_string();
        out.push((kind.to_string(), title));
    }
    out
}

/// Ordered slide titles (`P-title` paragraphs) from an ODP content.xml.
fn odp_titles(content: &str) -> Vec<String> {
    let mut out = Vec::new();
    for chunk in content.split("<draw:page ") {
        let Some(paras) = chunk.split("P-title\">").nth(1) else {
            continue;
        };
        out.push(paras.split("</text:p>").next().unwrap_or("").to_string());
    }
    out
}

/// Ordered `<h4>` section titles from a one-pager (goal, decisions, evidence).
fn one_pager_h4(html: &str) -> Vec<String> {
    let mut out = Vec::new();
    for chunk in html.split("<h4>").skip(1) {
        if let Some(title) = chunk.split("</h4>").next() {
            out.push(title.to_string());
        }
    }
    out
}

/// One-pager lesson bullet texts (timeline items carry a `<time>` element).
fn one_pager_lessons(html: &str) -> Vec<String> {
    let mut out = Vec::new();
    for chunk in html.split("<li>").skip(1) {
        if chunk.starts_with("<time>") {
            continue;
        }
        if let Some(text) = chunk.split("</li>").next()
            && !text.is_empty()
        {
            out.push(text.to_string());
        }
    }
    out
}

/// The plan's core regression: for one representative project with a saved
/// `StoryConfig`, every export renderer must present exactly the configured
/// story — same entities, same order, same current-state summary — with no
/// config re-derivation and no resurrection of hidden content.
/// Seed a representative project and save a `StoryConfig` that reverses the
/// decision order, hides d1 (and, via the parent rule, its experiment e1),
/// reverses the experiment order, keeps lessons, and replaces the problem.
async fn rich_seed_configured(
    db_url: &str,
) -> (Fixture, causelog_export::story_config::StoryConfig) {
    use causelog_export::story_config::{StoryConfig, StoryConfigItem};

    let fixture = seed(db_url).await;
    let repo = &fixture.repo;
    let pid = fixture.project_id;

    let goal = repo.list_goals(pid).await.unwrap().remove(0);

    // d1 "Pick a database" is already validated via its experiment's lesson.
    let d1 = repo
        .list_decisions(pid)
        .await
        .unwrap()
        .into_iter()
        .find(|d| d.title == "Pick a database")
        .unwrap();

    let d2 = repo
        .create_decision(
            pid,
            Some(goal.id),
            "Move to Aurora",
            "Saturating the boring path.",
            &[DecisionOption {
                id: "aurora".into(),
                label: "Aurora".into(),
                pros: "Boring.".into(),
                cons: "Pricier.".into(),
            }],
            None,
        )
        .await
        .unwrap();
    repo.resolve_decision(
        d2.id,
        "decided",
        Some("aurora".into()),
        "Boring wins.",
        None,
    )
    .await
    .unwrap();

    let d3 = repo
        .create_decision(
            pid,
            Some(goal.id),
            "Switch grinder",
            "The old one burned out twice.",
            &[DecisionOption {
                id: "burr".into(),
                label: "Burr grinder".into(),
                pros: "Survives the rush.".into(),
                cons: "Costs more.".into(),
            }],
            None,
        )
        .await
        .unwrap();

    let e1 = repo
        .list_experiments(pid)
        .await
        .unwrap()
        .into_iter()
        .find(|e| e.title == "Volume probe")
        .unwrap();

    let e2 = repo
        .create_experiment(pid, None, None, "Dark deploy", "Ships invisibly?", None)
        .await
        .unwrap();
    repo.update_experiment(
        e2.id,
        "Dark deploy",
        "Ships invisibly?",
        "done",
        "Deployed.",
        "Lesson: dark first.",
    )
    .await
    .unwrap();

    let config = StoryConfig {
        sections: [
            ("problem".to_string(), true),
            ("decisions".to_string(), true),
            ("lessons".to_string(), true),
            ("current_state".to_string(), true),
        ]
        .into_iter()
        .collect(),
        order: vec![
            "problem".to_string(),
            "decisions".to_string(),
            "lessons".to_string(),
            "current_state".to_string(),
        ],
        problem: Some("The real bottleneck is waking up.".to_string()),
        // Reversed order, d1 hidden: parent rule must hide its experiment too.
        decisions: vec![
            StoryConfigItem {
                id: d3.id,
                on: true,
                summary: None,
            },
            StoryConfigItem {
                id: d1.id,
                on: false,
                summary: None,
            },
            StoryConfigItem {
                id: d2.id,
                on: true,
                summary: None,
            },
        ],
        experiments: vec![
            StoryConfigItem {
                id: e2.id,
                on: true,
                summary: None,
            },
            StoryConfigItem {
                id: e1.id,
                on: true,
                summary: None,
            },
        ],
        lessons: vec![],
    };

    (fixture, config)
}

#[tokio::test]
async fn configured_story_is_identical_across_all_export_renderers() {
    use causelog_export::odp::build_presentation;
    use causelog_export::odp::render_odp;
    use causelog_export::one_pager::one_pager_html;
    use causelog_export::story_config::build_story_with_config;

    let dir = tempfile::tempdir().unwrap();
    let db = dir.path().join("test.db");
    let (fixture, config) = rich_seed_configured(&format!("sqlite://{}", db.display())).await;
    let repo = &fixture.repo;
    let pid = fixture.project_id;
    repo.set_story_config(pid, &serde_json::to_string(&config).unwrap())
        .await
        .unwrap();

    let snapshot = repo.collect_project_snapshot(pid).await.unwrap();
    let saved = repo.get_story_config(pid).await.unwrap().unwrap();
    let cfg: causelog_export::story_config::StoryConfig = serde_json::from_str(&saved).unwrap();
    let story = build_story_with_config(&snapshot, Some(&cfg));

    let decision_titles: Vec<String> = story
        .key_decisions
        .iter()
        .map(|d| d.title.clone())
        .collect();
    let experiment_titles: Vec<String> =
        story.experiments.iter().map(|e| e.title.clone()).collect();
    let lesson_texts: Vec<String> = story.lessons.iter().map(|l| l.text.clone()).collect();
    let current: Vec<String> = story
        .current_state
        .iter()
        .map(|s| s.title.clone())
        .collect();
    let chain: Vec<(String, String)> = causelog_export::story_chain(&story)
        .into_iter()
        .map(|e| (e.kind.to_string(), e.title.clone()))
        .collect();

    // Config applied: d1 hidden (and its experiment e1), d2 + d3 visible.
    assert_eq!(decision_titles, vec!["Switch grinder", "Move to Aurora"]);
    assert_eq!(experiment_titles, vec!["Dark deploy"]);
    assert_eq!(chain[0], ("goal".to_string(), "Aim high".to_string()));
    // The selected story really is what the web and the exports share.
    let current_tally = story_state_tally_of(&story);

    // Markdown README: `## Story` reproduces the chain verbatim.
    let md_files = causelog_export::markdown::render_markdown(&snapshot, &story);
    let readme = &md_files
        .iter()
        .find(|f| f.path == "README.md")
        .unwrap()
        .content;
    assert_eq!(md_chain(readme), chain, "markdown story != canonical");
    for title in &decision_titles {
        assert!(readme.contains(title));
    }
    assert!(
        !md_chain(readme).iter().any(|(_, t)| t == "Pick a database"),
        "hidden decision resurrected in the markdown story"
    );
    assert!(readme.contains("The real bottleneck is waking up."));
    for (state, n) in &current_tally {
        assert!(
            readme.contains(&format!("{n} {state}")),
            "markdown tally section"
        );
    }

    // HTML index: the Story block reproduces the chain, chips the tally.
    let html_files = causelog_export::html::render_html(&snapshot, &story);
    let index = &html_files
        .iter()
        .find(|f| f.path == "index.html")
        .unwrap()
        .content;
    assert_eq!(html_chain(index), chain, "html story != canonical");
    assert!(
        !html_chain(index)
            .iter()
            .any(|(_, t)| t == "Pick a database"),
        "hidden decision resurrected in the html story"
    );
    assert!(index.contains("The real bottleneck is waking up."));
    for (state, n) in &current_tally {
        assert!(
            index.contains(&format!(">{n} {state}<")),
            "html chips: {n} {state}"
        );
    }

    // ODP: slides follow the configured key-decisions / experiments order.
    let p = build_presentation(&story);
    let bytes = render_odp(&p, &snapshot.causelog_version).unwrap();
    let mut content = String::new();
    {
        let mut zip = zip::ZipArchive::new(std::io::Cursor::new(&bytes[..])).unwrap();
        use std::io::Read;
        let mut entry = zip.by_name("content.xml").unwrap();
        entry.read_to_string(&mut content).unwrap();
    }
    let titles = odp_titles(&content);
    let shown_decisions: Vec<&String> = titles
        .iter()
        .filter(|t| decision_titles.contains(t))
        .collect();
    assert_eq!(
        shown_decisions,
        decision_titles.iter().collect::<Vec<_>>(),
        "odp decision order"
    );
    let shown_experiments: Vec<&String> = titles
        .iter()
        .filter(|t| experiment_titles.contains(t))
        .collect();
    assert_eq!(
        shown_experiments,
        experiment_titles.iter().collect::<Vec<_>>(),
        "odp experiment order"
    );
    // The hidden decision has no slide (the lossless Timeline still names it,
    // just like the entity index listings in the docs tree).
    assert!(
        !titles.iter().any(|t| t == "Pick a database"),
        "hidden decision resurrected as a slide"
    );

    // One-pager: Decisions, Evidence and Lessons sections in configured order.
    let op = one_pager_html(&story, &[]);
    let h4 = one_pager_h4(&op);
    let mut idx = if story.goal.is_some() { 1 } else { 0 };
    for t in &decision_titles {
        assert_eq!(&h4[idx], t, "one-pager decision order");
        idx += 1;
    }
    for t in &experiment_titles {
        assert_eq!(&h4[idx], t, "one-pager evidence order");
        idx += 1;
    }
    assert_eq!(one_pager_lessons(&op), lesson_texts, "one-pager lessons");

    // Current-state summary is the same story data in Markdown and HTML.
    assert_eq!(
        current,
        vec!["Move to Aurora"],
        "only decided & visible decisions"
    );
    let tally_once = story_state_tally_of(&story);
    assert_eq!(tally_once, current_tally, "tally must be stable");
}

/// Count knowledge states in a configured story, the same way the renderers'
/// (private) `story_state_tally` does.
fn story_state_tally_of(story: &causelog_export::story::ProjectStory) -> Vec<(String, usize)> {
    let mut counts: std::collections::HashMap<String, usize> = std::collections::HashMap::new();
    for d in &story.key_decisions {
        if !d.state.is_empty() {
            *counts.entry(d.state.clone()).or_insert(0) += 1;
        }
    }
    let mut out: Vec<(String, usize)> = counts.into_iter().collect();
    out.sort();
    out
}
