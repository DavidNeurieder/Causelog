//! Causelog export: a canonical, versioned project snapshot plus pure
//! renderers that turn it into JSON, a Markdown directory, or an offline
//! static HTML site.
//!
//! The pipeline is deliberately one-way:
//!
//! ```text
//! Repository (ExportSource) ─▶ ExportProject ─▶ ProjectStory ─▶ JSON / Markdown / HTML / ODP
//!                                              └─ apply StoryConfig ──▶ configured ProjectStory ─ Everywhere
//! ```
//!
//! Renderers never touch storage; they consume a fully populated
//! [`ExportProject`] (and a configured [`ProjectStory`] where the human-facing
//! narrative is involved). Collection (the only code that talks to an
//! [`ExportSource`]) is kept separate so the export format stays stable even
//! when the database schema changes.

pub mod archive;
pub mod collect;
pub mod html;
pub mod json;
pub mod markdown;
pub mod model;
pub mod odp;
pub mod one_pager;
pub mod story;
pub mod story_config;
pub mod timeline;

pub use archive::{
    ARCHIVE_FORMAT, ARCHIVE_SCHEMA_VERSION, ARCHIVE_VERSION, ArchiveError, Manifest, ManifestFile,
    ManifestProject, archive, zip_files,
};
pub use collect::{ExportSource, collect, resolve_project};
pub use model::{
    EXPORT_FORMAT, EXPORT_VERSION, ExportDecision, ExportFormat, ExportProject, ExportRevision,
    TimelineEvent, slugify,
};
pub use odp::{OdfError, Presentation, Slide, build_presentation, render_odp};
pub use story::{
    ProjectStory, StoryChainEntry, StoryDecision, StoryExperiment, StoryGoal, StoryLesson,
    StoryState, build_story, story_chain,
};
pub use story_config::{
    DEFAULT_SECTION_ORDER, StoryConfig, StoryConfigItem, apply_config, build_story_with_config,
    section_enabled,
};

/// One generated file of an export. Renderers return a flat list of these so
/// the CLI can write them to disk and tests can assert on them without I/O.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExportFile {
    /// Path relative to the export root, using `/` separators.
    pub path: String,
    pub content: String,
}
