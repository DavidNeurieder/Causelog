//! The project **story**: a curated, human-readable view of one project's
//! narrative, derived from the canonical [`ExportProject`]. One-pager and
//! slides (ODP) renderers share this model, so the same story drives every
//! communication format.
//!
//! Like the renderers, story building is a pure function: it never touches
//! storage and never invents text — it reshapes `ExportProject` data
//! (knowledge states arrive already attached to each [`ExportDecision`] via
//! collection).

use uuid::Uuid;

use crate::model::{ExportDecision, ExportProject, TimelineEvent};
use causelog_model::{DecisionOption, Experiment, ExperimentEvent};

/// The narrative of one project: goal → problem → decisions → experiments →
/// lessons → current state, plus the raw timeline.
#[derive(Debug, Clone, PartialEq)]
pub struct ProjectStory {
    pub title: String,
    pub summary: String,
    pub status: String,
    pub goal: Option<StoryGoal>,
    pub problem: Option<String>,
    pub key_decisions: Vec<StoryDecision>,
    pub experiments: Vec<StoryExperiment>,
    pub lessons: Vec<StoryLesson>,
    pub current_state: Vec<StoryState>,
    pub timeline: Vec<TimelineEvent>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct StoryGoal {
    pub id: Uuid,
    pub title: String,
    pub body: String,
    /// `open` | `done` | `dropped`
    pub status: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct StoryDecision {
    pub id: Uuid,
    pub title: String,
    /// `validated` | `unvalidated` | `superseded` | `invalidated` | `open`
    pub state: String,
    pub decided_option: Option<String>,
    pub context: String,
    pub rationale: String,
    pub options: Vec<DecisionOption>,
    /// Explicit edges from the export: `(kind, other-entity-id)`.
    pub links: Vec<(String, Uuid)>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct StoryExperiment {
    pub id: Uuid,
    /// The decision this experiment resolves, if any. Carried so configuration
    /// can enforce the parent rule (an experiment cannot appear when its
    /// parent decision is excluded) and so renderers can group it under the
    /// right decision.
    pub decision_id: Option<Uuid>,
    pub title: String,
    /// `planned` | `running` | `done` | `abandoned`
    pub status: String,
    pub hypothesis: String,
    pub result: String,
    pub lesson: String,
    pub events: Vec<ExperimentEvent>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct StoryLesson {
    pub id: Uuid,
    pub text: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct StoryState {
    pub decision_id: Uuid,
    pub title: String,
    /// `validated` | `unvalidated` | `superseded` | `invalidated`
    pub state: String,
}

/// Build the story for a project export.
pub fn build_story(project: &ExportProject) -> ProjectStory {
    let goal = single_open_goal(project);
    ProjectStory {
        title: project.project.title.clone(),
        summary: project.project.summary.clone(),
        status: project.project.status.clone(),
        goal: goal.clone(),
        problem: goal.as_ref().map(|g| g.body.clone()).or_else(|| {
            let s = project.project.summary.trim();
            if s.is_empty() {
                None
            } else {
                Some(s.to_string())
            }
        }),
        key_decisions: project
            .decisions
            .iter()
            .map(|d| story_decision(d, &project.links))
            .collect(),
        experiments: project
            .experiments
            .iter()
            .map(|e| story_experiment(e, &project.events))
            .collect(),
        lessons: {
            let mut seen = std::collections::HashSet::new();
            project
                .experiments
                .iter()
                .filter_map(|e| {
                    let text = e.lesson.trim();
                    if text.is_empty() || !seen.insert(text.to_string()) {
                        None
                    } else {
                        Some(StoryLesson {
                            id: e.id,
                            text: text.to_string(),
                        })
                    }
                })
                .collect()
        },
        current_state: project
            .decisions
            .iter()
            .filter_map(|d| {
                d.state.as_deref().map(|s| StoryState {
                    decision_id: d.id,
                    title: d.title.clone(),
                    state: s.to_string(),
                })
            })
            .collect(),
        timeline: crate::timeline::derive_timeline(project),
    }
}

/// The single open goal of the project, if exactly one (matching how the
/// dashboard picks a headline goal). Otherwise `None`.
fn single_open_goal(project: &ExportProject) -> Option<StoryGoal> {
    let open: Vec<&causelog_model::Goal> = project
        .goals
        .iter()
        .filter(|g| g.status == "open")
        .collect();
    match open.len() {
        1 => open.first().map(|g| StoryGoal {
            id: g.id,
            title: g.title.clone(),
            body: g.body.clone(),
            status: g.status.clone(),
        }),
        // Zero or several open goals: no unambiguous headline goal.
        _ => None,
    }
}

fn story_decision(d: &ExportDecision, links: &[causelog_model::Link]) -> StoryDecision {
    let entity_links = links
        .iter()
        .filter(|l| l.from_id == d.id || l.to_id == d.id)
        .map(|l| {
            let other = if l.from_id == d.id {
                l.to_id
            } else {
                l.from_id
            };
            (l.kind.clone(), other)
        })
        .collect();
    StoryDecision {
        id: d.id,
        title: d.title.clone(),
        state: d.state.clone().unwrap_or_else(|| "open".to_string()),
        decided_option: d.decided_option.clone(),
        context: d.context.clone(),
        rationale: d.rationale.clone(),
        options: d.options.clone(),
        links: entity_links,
    }
}

fn story_experiment(e: &Experiment, events: &[ExperimentEvent]) -> StoryExperiment {
    StoryExperiment {
        id: e.id,
        decision_id: e.decision_id,
        title: e.title.clone(),
        status: e.status.clone(),
        hypothesis: e.hypothesis.clone(),
        result: e.result.clone(),
        lesson: e.lesson.clone(),
        events: events
            .iter()
            .filter(|ev| ev.experiment_id == e.id)
            .cloned()
            .collect(),
    }
}

/// One entity of the flat, ordered narrative chain used by the Markdown/HTML
/// renderers' "Story" sections. Derived exclusively from a (configured)
/// [`ProjectStory`], so excluded content can never be resurrected.
#[derive(Debug, Clone, PartialEq)]
pub struct StoryChainEntry {
    /// `goal` | `decision` | `experiment` | `lesson`
    pub kind: &'static str,
    pub title: String,
    pub id: Uuid,
    /// Knowledge-state / status tag, empty when not applicable.
    pub tag: String,
}

/// The narrative chain in configured order: goal → key decisions → experiments
/// → lessons. Mirrors exactly what the web story shows.
pub fn story_chain(story: &ProjectStory) -> Vec<StoryChainEntry> {
    let mut chain = Vec::new();
    if let Some(g) = &story.goal {
        chain.push(StoryChainEntry {
            kind: "goal",
            title: g.title.clone(),
            id: g.id,
            tag: g.status.clone(),
        });
    }
    for d in &story.key_decisions {
        chain.push(StoryChainEntry {
            kind: "decision",
            title: d.title.clone(),
            id: d.id,
            tag: d.state.clone(),
        });
    }
    for e in &story.experiments {
        chain.push(StoryChainEntry {
            kind: "experiment",
            title: e.title.clone(),
            id: e.id,
            tag: e.status.clone(),
        });
    }
    for l in &story.lessons {
        chain.push(StoryChainEntry {
            kind: "lesson",
            title: l.text.clone(),
            id: l.id,
            tag: String::new(),
        });
    }
    chain
}
