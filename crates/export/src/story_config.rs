//! Per-project story presentation config: which entities appear in a story,
//! in what order, and with which summaries. The UI's story editor writes
//! this; the story page and export renderers read it. Underlying records are
//! never modified.
//!
//! # Semantics
//!
//! `build_story_with_config` produces the **final** story every renderer and
//! the web story show; nothing downstream re-derives selection or ordering.
//! The rules are:
//!
//! * **Section visibility** — `sections[key] == false` hides a section;
//!   a missing key means visible (`section_on`).
//! * **Section ordering** — `order` lists the canonical section keys
//!   (`problem | decisions | lessons | current_state`) in display order;
//!   missing keys trail in canonical order (`effective_order`).
//! * **Entity selection** — a `decisions`/`experiments`/`lessons` entry with
//!   `on == false` hides that entity. Entities the editor has never seen
//!   (new records) default to visible.
//! * **Parent rule** — an experiment whose parent decision is excluded is
//!   excluded too, regardless of its own `on` flag, because an experiment
//!   only makes sense under the decision it resolves. Experiments without a
//!   parent decision are governed by their own flag.
//! * **Ordering** — `order` inside each list is respected; unlisted entities
//!   keep their canonical (build) position.
//! * **Custom problem** — `problem` replaces the derived problem statement
//!   verbatim (falling back to the derived one when empty).
//! * **Current state** — only decisions still visible after selection appear
//!   in `current_state`, so a hidden decision's chip never leaks into the
//!   story.
//! * **Stale ids** — entries whose id no longer exists in the story are
//!   ignored.

use std::collections::HashMap;
use std::collections::HashSet;

use uuid::Uuid;

use serde::{Deserialize, Serialize};

/// Story section keys in their default display order.
pub const DEFAULT_SECTION_ORDER: &[&str] = &["problem", "decisions", "lessons", "current_state"];

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct StoryConfig {
    /// Section visibility: `problem | decisions | lessons | current_state`.
    /// A missing key means the section is visible.
    #[serde(default)]
    pub sections: HashMap<String, bool>,
    /// Section display order (subset of the keys above).
    #[serde(default)]
    pub order: Vec<String>,
    /// Optional problem one-liner shown verbatim as the story lede.
    #[serde(default)]
    pub problem: Option<String>,
    #[serde(default)]
    pub decisions: Vec<StoryConfigItem>,
    #[serde(default)]
    pub experiments: Vec<StoryConfigItem>,
    #[serde(default)]
    pub lessons: Vec<StoryConfigItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StoryConfigItem {
    pub id: Uuid,
    #[serde(default = "default_on")]
    pub on: bool,
    /// Optional one-line summary override.
    #[serde(default)]
    pub summary: Option<String>,
}

fn default_on() -> bool {
    true
}

impl StoryConfig {
    /// Whether a named section is visible (missing = visible by default).
    pub fn section_on(&self, key: &str) -> bool {
        self.sections.get(key).copied().unwrap_or(true)
    }

    /// Display order of all known sections, defaulting missing keys to the
    /// tail in canonical order.
    pub fn effective_order(&self) -> Vec<String> {
        let mut order: Vec<String> = self
            .order
            .iter()
            .filter(|k| DEFAULT_SECTION_ORDER.contains(&k.as_str()))
            .cloned()
            .collect();
        for key in DEFAULT_SECTION_ORDER {
            if !order.iter().any(|k| k == key) {
                order.push(key.to_string());
            }
        }
        order
    }

    /// A single `on` flag for an entity id in `items`; entities never seen by
    /// the editor (new records) default to visible.
    pub fn on(&self, items: &[StoryConfigItem], id: Uuid) -> bool {
        items
            .iter()
            .find(|i| i.id == id)
            .map(|i| i.on)
            .unwrap_or(true)
    }

    /// Summary override for an entity id, if the editor saved one.
    pub fn summary(&self, items: &[StoryConfigItem], id: Uuid) -> Option<String> {
        items
            .iter()
            .find(|i| i.id == id)
            .and_then(|i| i.summary.clone())
    }

    /// The problem one-liner to show, falling back to the derived problem.
    pub fn effective_problem(&self, derived: &Option<String>) -> Option<String> {
        self.problem
            .clone()
            .filter(|p| !p.trim().is_empty())
            .or_else(|| derived.clone().filter(|p| !p.trim().is_empty()))
    }
}

/// Order a list of entity ids per the saved order; entities the editor has
/// never seen keep their canonical position.
fn order_ids(story_ids: &[Uuid], configured: &[StoryConfigItem]) -> Vec<Uuid> {
    let asked: Vec<Uuid> = configured
        .iter()
        .map(|i| i.id)
        .filter(|id| story_ids.contains(id))
        .collect();
    let mut ordered: Vec<Uuid> = story_ids
        .iter()
        .filter(|id| !asked.contains(id))
        .copied()
        .collect();
    asked.into_iter().rev().for_each(|id| ordered.insert(0, id));
    ordered
}

/// Apply a saved presentation config to a derived story: hide deselected
/// entities, apply summary overrides, honor the saved ordering, enforce the
/// parent rule, and drop hidden decisions from the current-state list. The
/// source records never change. The returned story IS the final story that
/// every renderer shows.
pub fn apply_config(
    mut story: crate::story::ProjectStory,
    config: &StoryConfig,
) -> crate::story::ProjectStory {
    use crate::story::StoryLesson;

    story.problem = config.effective_problem(&story.problem);

    let decision_ids = order_ids(
        &story.key_decisions.iter().map(|d| d.id).collect::<Vec<_>>(),
        &config.decisions,
    );
    story.key_decisions = decision_ids
        .into_iter()
        .filter(|id| config.on(&config.decisions, *id))
        .filter_map(|id| story.key_decisions.iter().find(|d| d.id == id).cloned())
        .collect();
    let visible_decisions: HashSet<Uuid> = story.key_decisions.iter().map(|d| d.id).collect();

    let experiment_ids = order_ids(
        &story.experiments.iter().map(|e| e.id).collect::<Vec<_>>(),
        &config.experiments,
    );
    story.experiments = experiment_ids
        .into_iter()
        .filter_map(|id| {
            let e = story.experiments.iter().find(|e| e.id == id)?;
            if !config.on(&config.experiments, id) {
                return None;
            }
            // Parent rule: an experiment cannot appear if its parent decision
            // is excluded, whatever its own flag says.
            match e.decision_id {
                Some(did) if !visible_decisions.contains(&did) => None,
                _ => Some(id),
            }
        })
        .filter_map(|id| story.experiments.iter().find(|e| e.id == id).cloned())
        .collect();

    let lesson_ids = order_ids(
        &story.lessons.iter().map(|l| l.id).collect::<Vec<_>>(),
        &config.lessons,
    );
    let lessons = lesson_ids
        .into_iter()
        .filter(|id| config.on(&config.lessons, *id))
        .filter_map(|id| story.lessons.iter().find(|l| l.id == id))
        .cloned()
        .collect::<Vec<StoryLesson>>();
    story.lessons = lessons
        .into_iter()
        .map(|mut l| {
            if let Some(s) = config.summary(&config.lessons, l.id) {
                l.text = s;
            }
            l
        })
        .collect();

    story.current_state = story
        .current_state
        .iter()
        .filter(|s| visible_decisions.contains(&s.decision_id))
        .cloned()
        .collect();

    story
}

/// Build the story for a project, then apply an optional saved presentation
/// config (selection, ordering, summaries).
pub fn build_story_with_config(
    project: &crate::model::ExportProject,
    config: Option<&StoryConfig>,
) -> crate::story::ProjectStory {
    let story = crate::build_story(project);
    match config {
        Some(cfg) => apply_config(story, cfg),
        None => story,
    }
}

/// Whether a section is enabled, falling back to the canonical default.
pub fn section_enabled(config: Option<&StoryConfig>, key: &str) -> bool {
    config.map(|c| c.section_on(key)).unwrap_or(true)
}
