//! Causelog export: a canonical, versioned project snapshot plus pure
//! renderers that turn it into JSON, a Markdown directory, or an offline
//! static HTML site.
//!
//! The pipeline is deliberately one-way:
//!
//! ```text
//! Repository (ExportSource) ─▶ ExportProject ─▶ JSON / Markdown / HTML
//! ```
//!
//! Renderers never touch storage; they consume a fully populated
//! [`ExportProject`]. Collection (the only code that talks to a
//! [`ExportSource`]) is kept separate so the export format stays stable even
//! when the database schema changes.

pub mod archive;
pub mod collect;
pub mod html;
pub mod json;
pub mod markdown;
pub mod model;
pub mod odp;
pub mod story;
pub mod timeline;

pub use archive::{Manifest, ManifestFile, ManifestProject, archive};
pub use collect::{ExportSource, collect, resolve_project};
pub use model::{
    EXPORT_FORMAT, EXPORT_VERSION, ExportDecision, ExportFormat, ExportProject, ExportRevision,
    TimelineEvent, slugify,
};
pub use odp::{Presentation, Slide, build_presentation, render_odp};
pub use story::{
    ProjectStory, StoryDecision, StoryExperiment, StoryGoal, StoryLesson, StoryState, build_story,
};

/// One generated file of an export. Renderers return a flat list of these so
/// the CLI can write them to disk and tests can assert on them without I/O.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExportFile {
    /// Path relative to the export root, using `/` separators.
    pub path: String,
    pub content: String,
}
