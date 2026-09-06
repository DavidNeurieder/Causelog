//! Pure `ProjectStory` tests: a hand-built fixture exercises aggregation
//! rules (single open goal, deduplicated lessons, knowledge states, links,
//! experiment events, timeline reuse).

use std::str::FromStr;

use causelog_export::story::build_story;
use causelog_model::{DecisionOption, Experiment, ExperimentEvent, Goal, Link, Note, Project};
use uuid::Uuid;

use causelog_export::ExportProject as EP;
use causelog_export::model::ExportDecision;

fn id(s: &str) -> Uuid {
    Uuid::from_str(s).unwrap()
}

fn project() -> Project {
    Project {
        id: id("11111111-1111-1111-1111-111111111111"),
        title: "Coffee Machine Uprising".into(),
        summary: "They will not grind us down.".into(),
        status: "active".into(),
        created_by: None,
        created_at_ms: 1_700_000_000_000,
        updated_at_ms: 1_700_000_000_000,
    }
}

/// A populated export with:
/// - exactly one open goal (so `story.goal` is populated)
/// - one validated decision (done experiment with lesson + supports link)
/// - one unvalidated decision (decided, no lesson — so its state comes from
///   the export's attached state)
/// - one open (undecided) decision → story state `open`
/// - a done experiment with a lesson and an event
/// - a link `experiment:... supports decision:...`
fn fixture() -> EP {
    let p = project();
    let mut ep = EP::new(p.clone(), 1_700_000_100_000, "test-version");

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

    let validated = ExportDecision {
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

    let unvalidated = ExportDecision {
        id: id("44444444-4444-4444-4444-444444444444"),
        project_id: p.id,
        goal_id: Some(goal.id),
        title: "Open a second queue".into(),
        context: "Lunch lines are long.".into(),
        options: vec![],
        status: "decided".into(),
        decided_option: None,
        rationale: "Cheap to test.".into(),
        decided_at_ms: Some(1_700_000_030_000),
        review_at_ms: None,
        created_by: None,
        created_at_ms: 1_700_000_025_000,
        updated_at_ms: 1_700_000_030_000,
        state: Some("unvalidated".into()),
    };
    ep.decisions.push(unvalidated.clone());

    let open = ExportDecision {
        id: id("55555555-5555-5555-5555-555555555555"),
        project_id: p.id,
        goal_id: Some(goal.id),
        title: "Replay the software".into(),
        context: "Firmware keeps overriding our settings.".into(),
        options: vec![],
        status: "open".into(),
        decided_option: None,
        rationale: String::new(),
        decided_at_ms: None,
        review_at_ms: None,
        created_by: None,
        created_at_ms: 1_700_000_035_000,
        updated_at_ms: 1_700_000_035_000,
        state: None,
    };
    ep.decisions.push(open.clone());

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

#[test]
fn story_aggregates_entities_and_state() {
    let ep = fixture();
    let story = build_story(&ep);
    let validated = &ep.decisions[0];
    let unvalidated = &ep.decisions[1];

    assert_eq!(story.title, "Coffee Machine Uprising");
    assert_eq!(story.status, "active");
    assert_eq!(story.summary, "They will not grind us down.");

    let goal = story.goal.as_ref().expect("one open goal");
    assert_eq!(goal.title, "Serve coffee humans want");
    assert_eq!(
        story.problem.as_deref(),
        Some("Reduce daily grinder failures to zero.")
    );

    assert_eq!(story.key_decisions.len(), 3);
    let s: Vec<(&str, &str)> = story
        .key_decisions
        .iter()
        .map(|d| (d.title.as_str(), d.state.as_str()))
        .collect();
    assert_eq!(
        s,
        vec![
            ("Buy a heavier grinder", "validated"),
            ("Open a second queue", "unvalidated"),
            ("Replay the software", "open"),
        ]
    );

    assert_eq!(story.experiments.len(), 1);
    let ex = &story.experiments[0];
    assert_eq!(ex.status, "done");
    assert_eq!(ex.lesson, "Buy the burr, skip the blade.");
    assert_eq!(ex.events.len(), 1);
    assert_eq!(ex.events[0].note, "120 shots during rush, 0 stalls.");

    assert_eq!(story.lessons.len(), 1);
    assert_eq!(story.lessons[0].text, "Buy the burr, skip the blade.");

    assert_eq!(
        story.current_state,
        vec![
            causelog_export::story::StoryState {
                decision_id: validated.id,
                title: "Buy a heavier grinder".into(),
                state: "validated".into(),
            },
            causelog_export::story::StoryState {
                decision_id: unvalidated.id,
                title: "Open a second queue".into(),
                state: "unvalidated".into(),
            },
        ]
    );
}

#[test]
fn story_goal_is_single_open_goal_else_none() {
    let p = project();
    let pid = p.id;
    let empty_g = |n: usize, status: &str| Goal {
        id: id(&format!("99999999-9999-9999-9999-9999999999{:02}", n)),
        project_id: pid,
        title: format!("goal {n}"),
        body: format!("body {n}"),
        status: status.into(),
        created_by: None,
        assigned_to: None,
        created_at_ms: 1_700_000_000_000,
        updated_at_ms: 1_700_000_000_000,
    };

    // No open goals → headline fallback to the summary, goal None.
    let mut ep = EP::new(p.clone(), 1, "test");
    ep.goals.push(empty_g(1, "done"));
    let story = build_story(&ep);
    assert!(story.goal.is_none());
    assert_eq!(
        story.problem.as_deref(),
        Some("They will not grind us down.")
    );

    // Two open goals → no headline goal.
    let mut ep = EP::new(p, 1, "test");
    ep.goals.push(empty_g(2, "open"));
    ep.goals.push(empty_g(3, "open"));
    let story = build_story(&ep);
    assert!(story.goal.is_none());
    assert_eq!(
        story.problem.as_deref(),
        Some("They will not grind us down.")
    );
}

#[test]
fn story_lessons_are_deduped_and_experiments_carry_events() {
    let mut ep = fixture();
    // Add a second experiment with the same lesson text as the first.
    let p = ep.project.clone();
    let dup = Experiment {
        id: id("77777777-7777-7777-7777-777777777777"),
        project_id: p.id,
        goal_id: None,
        decision_id: None,
        title: "Sibling trial".into(),
        hypothesis: "Boring hypothesis.".into(),
        status: "done".into(),
        started_at_ms: Some(1_700_000_040_000),
        ended_at_ms: Some(1_700_000_041_000),
        result: "Nothing new.".into(),
        lesson: "Buy the burr, skip the blade.".into(),
        created_by: None,
        created_at_ms: 1_700_000_039_000,
        updated_at_ms: 1_700_000_041_000,
    };
    ep.experiments.push(dup.clone());

    let story = build_story(&ep);
    assert_eq!(
        story.lessons.len(),
        1,
        "identical lesson text dedupes to a single story lesson"
    );

    let dup_story = story
        .experiments
        .iter()
        .find(|e| e.id == dup.id)
        .expect("dup experiment present");
    assert_eq!(dup_story.lesson, "Buy the burr, skip the blade.");
    assert!(dup_story.events.is_empty(), "no events attached to dup");
}

#[test]
fn story_timeline_matches_export_timeline() {
    let ep = fixture();
    let story = build_story(&ep);
    let derived = causelog_export::timeline::derive_timeline(&ep);
    assert_eq!(story.timeline, derived);
    assert!(!story.timeline.is_empty());
}

#[test]
fn story_config_applies_selection_ordering_and_summaries() {
    let ep = fixture();
    let story = build_story(&ep);

    // Grab the lesson id rather than guessing it: dedup rules decide which
    // note becomes the lesson.
    let lesson_id = story.lessons[0].id;

    let config = causelog_export::story_config::StoryConfig {
        problem: Some("Reduce grinder failures, for real.".into()),
        decisions: vec![
            causelog_export::story_config::StoryConfigItem {
                id: id("44444444-4444-4444-4444-444444444444"),
                on: true,
                summary: None,
            },
            causelog_export::story_config::StoryConfigItem {
                id: id("33333333-3333-3333-3333-333333333333"),
                on: true,
                summary: None,
            },
            causelog_export::story_config::StoryConfigItem {
                id: id("55555555-5555-5555-5555-555555555555"),
                on: false,
                summary: None,
            },
        ],
        experiments: vec![causelog_export::story_config::StoryConfigItem {
            id: id("66666666-6666-6666-6666-666666666666"),
            on: false,
            summary: None,
        }],
        lessons: vec![causelog_export::story_config::StoryConfigItem {
            id: lesson_id,
            on: true,
            summary: Some("Skip the blade.".into()),
        }],
        ..Default::default()
    };

    let applied = causelog_export::story_config::apply_config(story, &config);

    // Order honors the saved list; the deselected decision is gone.
    let decided: Vec<(&str, &str)> = applied
        .key_decisions
        .iter()
        .map(|d| (d.title.as_str(), d.state.as_str()))
        .collect();
    assert_eq!(
        decided,
        vec![
            ("Open a second queue", "unvalidated"),
            ("Buy a heavier grinder", "validated"),
        ]
    );

    // Hiding the experiment hides it everywhere (nested under decision).
    assert!(applied.experiments.is_empty());

    // Summary override replaces the lesson text, not the record.
    assert_eq!(applied.lessons.len(), 1);
    assert_eq!(applied.lessons[0].text, "Skip the blade.");
    assert_eq!(
        applied.problem.as_deref(),
        Some("Reduce grinder failures, for real.")
    );
}
