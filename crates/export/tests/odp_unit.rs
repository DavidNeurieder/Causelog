//! Pure `build_presentation` / `render_odp` tests: the bundle is a valid ZIP
//! with a stored, first `mimetype` entry; content.xml carries one page per
//! slide with the expected headings; and the story → slide mapping is
//! faithful. (A separate CLI smoke test opens the result in LibreOffice.)

use std::io::Read;
use std::str::FromStr;

use causelog_export::odp::{Slide, build_presentation, render_odp};
use causelog_export::story::build_story;
use causelog_model::{DecisionOption, Experiment, ExperimentEvent, Goal, Link, Note, Project};
use uuid::Uuid;

fn id(s: &str) -> Uuid {
    Uuid::from_str(s).unwrap()
}

/// The same populated fixture used by `story_unit`: one open goal, three
/// decisions (validated / unvalidated / open), a done experiment, a lesson,
/// a note, one link, and one measurement event.
fn ep() -> causelog_export::ExportProject {
    let p = Project {
        id: id("11111111-1111-1111-1111-111111111111"),
        title: "Coffee Machine Uprising".into(),
        summary: "They will not grind us down.".into(),
        status: "active".into(),
        created_by: None,
        created_at_ms: 1_700_000_000_000,
        updated_at_ms: 1_700_000_000_000,
    };
    let mut ep = causelog_export::ExportProject::new(p.clone(), 1_700_000_100_000, "test-version");

    let goal = Goal {
        id: id("22222222-2222-2222-2222-222222222222"),
        project_id: p.id,
        title: "Serve coffee humans want".into(),
        body: "Reduce daily grinder failures to zero.".into(),
        status: "open".into(),
        created_by: None,
        assigned_to: None,
        created_at_ms: 1_700_000_010_000,
        updated_at_ms: 1_700_000_010_000,
    };
    ep.goals.push(goal.clone());

    let validated = causelog_export::ExportDecision {
        id: id("33333333-3333-3333-3333-333333333333"),
        project_id: p.id,
        goal_id: Some(goal.id),
        title: "Buy a heavier grinder".into(),
        context: "The lightweight one burned out twice.".into(),
        options: vec![DecisionOption {
            id: "burr".into(),
            label: "Commercial burr grinder".into(),
            pros: "Handles the volume.".into(),
            cons: "Costs more.".into(),
        }],
        status: "decided".into(),
        decided_option: Some("burr".into()),
        rationale: "Matches our morning spike.".into(),
        decided_at_ms: Some(1_700_000_020_000),
        review_at_ms: None,
        created_by: None,
        created_at_ms: 1_700_000_015_000,
        updated_at_ms: 1_700_000_020_000,
        state: Some("validated".into()),
    };
    ep.decisions.push(validated.clone());

    let experiment = Experiment {
        id: id("66666666-6666-6666-6666-666666666666"),
        project_id: p.id,
        goal_id: Some(goal.id),
        decision_id: Some(validated.id),
        title: "Two-week burr trial".into(),
        hypothesis: "A burr grinder survives our morning rush.".into(),
        status: "done".into(),
        started_at_ms: Some(1_700_000_016_000),
        ended_at_ms: Some(1_700_000_021_000),
        result: "No more burned-out motors.".into(),
        lesson: "Buy the burr, skip the blade.".into(),
        created_by: None,
        created_at_ms: 1_700_000_014_000,
        updated_at_ms: 1_700_000_021_000,
    };
    ep.experiments.push(experiment.clone());

    ep.events.push(ExperimentEvent {
        id: id("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
        experiment_id: experiment.id,
        kind: "measurement".into(),
        at_ms: 1_700_000_018_000,
        note: "120 shots during rush, 0 stalls.".into(),
        created_at_ms: 1_700_000_018_000,
    });
    ep.notes.push(Note {
        id: id("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
        project_id: p.id,
        title: "Grinder maintenance".into(),
        body: "Descale weekly.".into(),
        source_type: Some("experiment".into()),
        source_id: Some(experiment.id),
        created_by: None,
        created_at_ms: 1_700_000_022_000,
        updated_at_ms: 1_700_000_022_000,
    });
    ep.links.push(Link {
        id: id("cccccccc-cccc-cccc-cccc-cccccccccccc"),
        project_id: p.id,
        from_type: "experiment".into(),
        from_id: experiment.id,
        to_type: "decision".into(),
        to_id: validated.id,
        kind: "supports".into(),
        created_at_ms: 1_700_000_021_000,
    });

    ep
}

fn stock() -> (causelog_export::Presentation, Vec<&'static str>) {
    let story = build_story(&ep());
    let p = build_presentation(&story);
    // Title, Goal, Decision (validated), Experiment, Lesson, Timeline.
    let expected = vec![
        "Coffee Machine Uprising",
        "Serve coffee humans want",
        "Buy a heavier grinder",
        "Two-week burr trial",
        "Buy the burr, skip the blade.",
        "Timeline",
    ];
    (p, expected)
}

fn read_entry(bytes: &[u8], name: &str) -> String {
    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(bytes)).unwrap();
    let mut out = String::new();
    let mut entry = archive.by_name(name).unwrap();
    entry.read_to_string(&mut out).unwrap();
    out
}

#[test]
fn bundle_is_a_zip_with_mimetype_manifest_and_content() {
    let (p, _) = stock();
    let bytes = render_odp(&p, "test-version");

    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(bytes)).unwrap();
    assert_eq!(archive.len(), 5);
    let mut names: Vec<String> = (0..archive.len())
        .map(|i| archive.by_index(i).unwrap().name().to_string())
        .collect();
    names.sort();
    assert_eq!(
        names,
        vec![
            "META-INF/manifest.xml",
            "content.xml",
            "meta.xml",
            "mimetype",
            "styles.xml",
        ]
    );
}

#[test]
fn bundle_entries_and_first_mimetype_stored() {
    let (p, _) = stock();
    let bytes = render_odp(&p, "test-version");

    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(bytes)).unwrap();
    let first_name = {
        let first = archive.by_index(0).unwrap();
        first.name().to_string()
    };
    assert_eq!(first_name, "mimetype");

    let names: Vec<String> = (0..archive.len())
        .map(|i| archive.by_index(i).unwrap().name().to_string())
        .collect();
    assert_eq!(
        names,
        vec![
            "mimetype",
            "content.xml",
            "styles.xml",
            "meta.xml",
            "META-INF/manifest.xml",
        ]
    );

    let compression = {
        let first = archive.by_index(0).unwrap();
        first.compression()
    };
    assert!(matches!(compression, zip::CompressionMethod::Stored));
}

#[test]
fn content_xml_has_one_page_per_slide_with_headings() {
    let (p, expected) = stock();
    let bytes = render_odp(&p, "test-version");
    let content = read_entry(&bytes, "content.xml");

    let pages = content.matches("<draw:page ").count();
    assert_eq!(pages, 6, "one draw:page per slide");
    for heading in expected {
        assert!(
            content.contains(heading),
            "content.xml should contain {heading:?}"
        );
    }
    assert!(content.contains("Decision · validated"));
    assert!(content.contains("Chosen: Commercial burr grinder"));
    assert!(content.contains("Experiment · done"));
    assert!(content.contains("What happened, in order"));
}

#[test]
fn presentation_slides_follow_the_story() {
    let (p, _) = stock();
    assert_eq!(p.title, "Coffee Machine Uprising");
    assert_eq!(p.slides.len(), 6);

    match &p.slides[0] {
        Slide::Title { title, subtitle } => {
            assert_eq!(title, "Coffee Machine Uprising");
            assert_eq!(subtitle, "They will not grind us down.");
        }
        other => panic!("expected title slide, got {other:?}"),
    }
    assert!(matches!(&p.slides[1], Slide::Goal { .. }));
    assert!(matches!(&p.slides[2], Slide::Decision { .. }));
    assert!(matches!(&p.slides[3], Slide::Experiment { .. }));
    assert!(matches!(&p.slides[4], Slide::Lesson { .. }));
    assert!(matches!(&p.slides[5], Slide::Timeline { .. }));
}

#[test]
fn minimal_presentation_still_renders_mimetype_first() {
    let story = build_story(&causelog_export::ExportProject::new(
        Project {
            id: id("11111111-1111-1111-1111-111111111111"),
            title: "Bare".into(),
            summary: String::new(),
            status: "active".into(),
            created_by: None,
            created_at_ms: 0,
            updated_at_ms: 0,
        },
        0,
        "test-version",
    ));
    let p = build_presentation(&story);
    assert_eq!(p.slides.len(), 1, "title slide only");

    let bytes = render_odp(&p, "test-version");
    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(bytes)).unwrap();
    let first = archive.by_index(0).unwrap();
    assert_eq!(first.name(), "mimetype");
}
