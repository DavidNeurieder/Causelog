//! Pure renderer tests: no database. A hand-built fixture project exercises
//! the canonical model, JSON, Markdown, HTML and the derived timeline.

use std::str::FromStr;

use causelog_export::ExportFormat;
use causelog_export::ExportProject as EP;
use causelog_export::markdown::render_markdown;
use causelog_export::model::{ExportDecision, ExportRevision};
use causelog_export::timeline::derive_timeline;
use causelog_model::{DecisionOption, Experiment, ExperimentEvent, Goal, Link, Note, Project};
use uuid::Uuid;

fn id(s: &str) -> Uuid {
    Uuid::from_str(s).unwrap()
}

fn fixture() -> EP {
    let project = Project {
        id: id("11111111-1111-1111-1111-111111111111"),
        title: "Payments Rewrite".into(),
        summary: "Move the billing service to Stripe.".into(),
        status: "active".into(),
        created_by: None,
        created_at_ms: 1_700_000_000_000,
        updated_at_ms: 1_700_000_000_000,
    };
    let mut ep = EP::new(project, 1_700_000_100_000, "test-version");

    let goal = Goal {
        id: id("22222222-2222-2222-2222-222222222222"),
        project_id: ep.project.id,
        title: "Ship a reliable billing API".into(),
        body: "Nobody likes surprise invoice webhooks.".into(),
        status: "open".into(),
        created_by: None,
        assigned_to: None,
        created_at_ms: 1_700_000_010_000,
        updated_at_ms: 1_700_000_010_000,
    };
    ep.goals.push(goal.clone());

    let decision = ExportDecision {
        id: id("33333333-3333-3333-3333-333333333333"),
        project_id: ep.project.id,
        goal_id: Some(goal.id),
        title: "Stripe or vendor-hosted billing?".into(),
        context: "The invoices kept bouncing between two old systems.".into(),
        options: vec![
            DecisionOption {
                id: "stripe".into(),
                label: "Stripe".into(),
                pros: "Boring and reliable.".into(),
                cons: "Not self-hosted.".into(),
            },
            DecisionOption {
                id: "recurly".into(),
                label: "Recurly".into(),
                pros: "Also boring.".into(),
                cons: "Less familiar.".into(),
            },
        ],
        status: "decided".into(),
        decided_option: Some("stripe".into()),
        rationale: "We already know how to debug it.".into(),
        decided_at_ms: Some(1_700_000_020_000),
        review_at_ms: Some(1_700_050_000_000),
        created_by: None,
        created_at_ms: 1_700_000_015_000,
        updated_at_ms: 1_700_000_020_000,
        state: Some("validated".into()),
    };
    ep.decisions.push(decision.clone());

    let experiment = Experiment {
        id: id("44444444-4444-4444-4444-444444444444"),
        project_id: ep.project.id,
        goal_id: Some(goal.id),
        decision_id: Some(decision.id),
        title: "Migration dry run".into(),
        hypothesis: "A shadow migration can run without touching production.".into(),
        status: "done".into(),
        started_at_ms: Some(1_700_000_018_000),
        ended_at_ms: Some(1_700_000_021_000),
        result: "All 40k invoice rows migrated cleanly.".into(),
        lesson: "Shadow first, always.".into(),
        created_by: None,
        created_at_ms: 1_700_000_016_000,
        updated_at_ms: 1_700_000_021_000,
    };
    ep.experiments.push(experiment.clone());

    ep.events.push(ExperimentEvent {
        id: id("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
        experiment_id: experiment.id,
        kind: "measurement".into(),
        at_ms: 1_700_000_019_000,
        note: "40k rows in 41s.".into(),
        created_at_ms: 1_700_000_019_000,
    });

    ep.notes.push(Note {
        id: id("55555555-5555-5555-5555-555555555555"),
        project_id: ep.project.id,
        title: "Invoice shape we must keep".into(),
        body: "# Payload\n\nThe `amount_cents` field is sacred.".into(),
        source_type: Some("decision".into()),
        source_id: Some(decision.id),
        created_by: None,
        created_at_ms: 1_700_000_017_000,
        updated_at_ms: 1_700_000_017_000,
    });

    ep.revisions.push(ExportRevision {
        id: id("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
        entity_type: "decision".into(),
        entity_id: decision.id,
        snapshot: "initial".into(),
        created_by: None,
        created_at_ms: 1_700_000_015_000,
    });

    ep.links.push(Link {
        id: id("cccccccc-cccc-cccc-cccc-cccccccccccc"),
        project_id: ep.project.id,
        from_type: "experiment".into(),
        from_id: experiment.id,
        to_type: "decision".into(),
        to_id: decision.id,
        kind: "supports".into(),
        created_at_ms: 1_700_000_021_000,
    });

    ep
}

#[test]
fn json_round_trip_preserves_everything() {
    let ep = fixture();
    let json = causelog_export::json::render_json(&ep).unwrap();
    let parsed: EP = serde_json::from_str(&json).unwrap();

    assert_eq!(parsed.format, "causelog-export");
    assert_eq!(parsed.version, 1);
    assert_eq!(parsed.causelog_version, "test-version");
    assert_eq!(parsed.project.title, "Payments Rewrite");
    assert_eq!(parsed.goals.len(), 1);
    assert_eq!(parsed.decisions.len(), 1);
    assert_eq!(parsed.experiments.len(), 1);
    assert_eq!(parsed.notes.len(), 1);
    assert_eq!(parsed.revisions.len(), 1);
    assert_eq!(parsed.events.len(), 1);
    assert_eq!(parsed.decisions[0].state.as_deref(), Some("validated"));
    assert_eq!(
        parsed.decisions[0].decided_option.as_deref(),
        Some("stripe")
    );
    assert_eq!(parsed.decisions[0].options[0].label, "Stripe");
    // A second serialization is byte-identical (stable field/entity order).
    let again = causelog_export::json::render_json(&ep).unwrap();
    assert_eq!(json, again);
}

#[test]
fn markdown_tree_has_frontmatter_and_files() {
    let files = render_markdown(&fixture());
    let names: Vec<&str> = files.iter().map(|f| f.path.as_str()).collect();

    assert!(names.contains(&"README.md"));
    assert!(names.contains(&"timeline.md"));
    assert!(names.contains(&"relationships.md"));
    let decision_path = names
        .iter()
        .find(|p| p.starts_with("decisions/stripe-or-vendor-hosted-billing"))
        .expect("decision page exists");
    let decision_md = &files
        .iter()
        .find(|f| f.path == *decision_path)
        .unwrap()
        .content;
    assert!(decision_md.starts_with("---\ntype: decision\nid: 33333333"));
    assert!(decision_md.contains("state: validated"));
    assert!(decision_md.contains("### Stripe _(chosen)_"));
    assert!(decision_md.contains("**Pros:**\n\nBoring and reliable."));

    let rel = files.iter().find(|f| f.path == "relationships.md").unwrap();
    assert!(rel.content.contains("--supports-->"));
    assert!(rel.content.contains("experiment:Migration dry run"));
}

#[test]
fn html_site_is_offline_and_complete() {
    let files = causelog_export::html::render_html(&fixture());
    let names: Vec<&str> = files.iter().map(|f| f.path.as_str()).collect();
    let mut all_content = String::new();
    for f in &files {
        all_content.push_str(&f.content);
    }

    assert!(names.contains(&"assets/styles.css"));
    assert!(names.contains(&"index.html"));
    assert!(names.contains(&"timeline.html"));
    assert!(names.contains(&"relationships.html"));
    assert!(
        names
            .iter()
            .any(|p| p.starts_with("decisions/stripe-or-vendor-hosted-billing"))
    );

    let index = &files
        .iter()
        .find(|f| f.path == "index.html")
        .unwrap()
        .content;
    assert!(index.contains("<title>Payments Rewrite</title>"));
    assert!(index.contains("state-validated"));
    assert!(index.contains("1 validated"));
    assert!(index.contains("Migration dry run"));
    // Lessons live on the experiment page, not the index.
    let experiment_page = files
        .iter()
        .find(|f| f.path.starts_with("experiments/migration-dry-run"))
        .unwrap();
    assert!(experiment_page.content.contains("Shadow first, always."));
    assert!(experiment_page.content.contains("Lesson"));

    // No external resources anywhere; every link is relative on-disk.
    assert!(!all_content.contains("https://"));
    assert!(!all_content.contains("http://"));
    assert!(!all_content.contains("src=\"//"));
}

#[test]
fn timeline_is_chronological_and_complete() {
    let events = derive_timeline(&fixture());
    let kinds: Vec<&str> = events.iter().map(|e| e.kind.as_str()).collect();
    assert!(kinds.contains(&"experiment_started"));
    assert!(kinds.contains(&"experiment_ended"));
    assert!(kinds.contains(&"decision_resolved"));
    assert!(kinds.contains(&"measurement"));
    let mut sorted = events.clone();
    sorted.sort_by_key(|e| e.at_ms);
    assert_eq!(events, sorted);
    let resolved = events
        .iter()
        .find(|e| e.kind == "decision_resolved")
        .unwrap();
    assert!(resolved.title.contains("Stripe or vendor-hosted billing?"));
    assert!(resolved.detail.contains("Stripe"));
}

#[test]
fn slugify_handles_garbage() {
    assert_eq!(causelog_export::slugify("Use Stripe?"), "use-stripe");
    assert_eq!(causelog_export::slugify("  "), "item");
    assert_eq!(causelog_export::slugify("A  B--C!"), "a-b-c");
    assert_eq!(causelog_export::slugify("Éclair Test"), "éclair-test");
}

#[test]
fn export_format_value_enum_maps() {
    assert_eq!(ExportFormat::Json.as_str(), "json");
    assert_eq!(ExportFormat::Markdown.as_str(), "markdown");
    assert_eq!(ExportFormat::Html.as_str(), "html");
    assert_eq!(ExportFormat::Archive.as_str(), "archive");
}
