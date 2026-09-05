//! The canonical export model. These structs are the **export format**, not a
//! mirror of the database: they stay stable as the schema evolves and are the
//! only shape the renderers and a future importer rely on.

use causelog_model::{DecisionOption, Project};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Envelope identifier for any export produced by Causelog.
pub const EXPORT_FORMAT: &str = "causelog-export";
/// Current export format version. Bump whenever the canonical model changes.
pub const EXPORT_VERSION: u32 = 1;

/// CLI/value-level spelling of each supported output format.
#[derive(Debug, Clone, Copy, PartialEq, Eq, clap::ValueEnum)]
pub enum ExportFormat {
    /// Canonical versioned JSON snapshot (single file or stdout).
    Json,
    /// Git-friendly directory of Markdown files.
    Markdown,
    /// Self-contained offline static HTML site (directory).
    Html,
}

impl ExportFormat {
    pub fn as_str(self) -> &'static str {
        match self {
            ExportFormat::Json => "json",
            ExportFormat::Markdown => "markdown",
            ExportFormat::Html => "html",
        }
    }
}

/// Everything belonging to one project, in one versioned envelope.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ExportProject {
    pub format: String,
    pub version: u32,
    pub exported_at_ms: i64,
    pub causelog_version: String,
    pub project: Project,
    pub goals: Vec<causelog_model::Goal>,
    pub decisions: Vec<ExportDecision>,
    pub experiments: Vec<causelog_model::Experiment>,
    pub notes: Vec<causelog_model::Note>,
    /// Immutable revision snapshots, oldest first, batched across entities.
    pub revisions: Vec<ExportRevision>,
    pub links: Vec<causelog_model::Link>,
    /// Raw experiment events (observations, measurements, milestones).
    pub events: Vec<causelog_model::ExperimentEvent>,
}

impl ExportProject {
    pub fn new(project: Project, exported_at_ms: i64, causelog_version: &str) -> ExportProject {
        ExportProject {
            format: EXPORT_FORMAT.to_string(),
            version: EXPORT_VERSION,
            exported_at_ms,
            causelog_version: causelog_version.to_string(),
            project,
            goals: Vec::new(),
            decisions: Vec::new(),
            experiments: Vec::new(),
            notes: Vec::new(),
            revisions: Vec::new(),
            links: Vec::new(),
            events: Vec::new(),
        }
    }

    /// Empty in the sense of having no entities at all (an empty project is
    /// still a valid export).
    pub fn is_empty_project(&self) -> bool {
        self.goals.is_empty()
            && self.decisions.is_empty()
            && self.experiments.is_empty()
            && self.notes.is_empty()
            && self.revisions.is_empty()
            && self.links.is_empty()
            && self.events.is_empty()
    }
}

/// A decision as exported: the decision itself plus its derived knowledge
/// state (`validated` / `unvalidated` / `invalidated` / `superseded`, or
/// absent for decisions that have not been made).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ExportDecision {
    pub id: Uuid,
    pub project_id: Uuid,
    pub goal_id: Option<Uuid>,
    pub title: String,
    pub context: String,
    pub options: Vec<DecisionOption>,
    pub status: String,
    pub decided_option: Option<String>,
    pub rationale: String,
    pub decided_at_ms: Option<i64>,
    pub review_at_ms: Option<i64>,
    pub created_by: Option<Uuid>,
    pub created_at_ms: i64,
    pub updated_at_ms: i64,
    pub state: Option<String>,
}

/// One immutable revision snapshot (`decision` or `note`), oldest first.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ExportRevision {
    pub id: Uuid,
    pub entity_type: String,
    pub entity_id: Uuid,
    pub snapshot: String,
    pub created_by: Option<Uuid>,
    pub created_at_ms: i64,
}

/// A single derived timeline entry, produced by [`crate::timeline`] from the
/// entity and event timestamps rather than stored in the database.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct TimelineEvent {
    pub at_ms: i64,
    /// `experiment_started` | `experiment_ended` | `decision_resolved` |
    /// one of the experiment event kinds (`observation` | `measurement` |
    /// `milestone`).
    pub kind: String,
    /// Human-readable heading, e.g. the experiment title.
    pub title: String,
    /// Optional supporting text (event note, rationale snippet).
    pub detail: String,
}

/// Slugify a title for use in export filenames: lowercase, non-alphanumeric
/// runs become single `-`, trimmed. Falls back to `item` when empty.
pub fn slugify(title: &str) -> String {
    let mut out = String::with_capacity(title.len());
    let mut last_dash = false;
    for ch in title.to_lowercase().chars() {
        if ch.is_alphanumeric() {
            out.push(ch);
            last_dash = false;
        } else if !out.is_empty() && !last_dash {
            out.push('-');
            last_dash = true;
        }
    }
    while out.ends_with('-') {
        out.pop();
    }
    if out.is_empty() {
        "item".to_string()
    } else {
        out
    }
}

/// Stable, unique file stem for an entity: `<slug>-<first-id-bytes>`.
pub fn file_stem(title: &str, id: Uuid) -> String {
    format!("{}-{}", slugify(title), &id.to_string()[..8])
}
