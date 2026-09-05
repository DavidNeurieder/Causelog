//! JSON renderer: the canonical, versioned snapshot. This is the reference
//! serialization the Markdown/HTML renderers and any future importer agree on.

use crate::model::ExportProject;

/// Serialize the project into its canonical JSON form. Deterministic for a
/// given database (entity ordering is fixed at collection time; field order
/// follows the struct definitions), pretty-printed UTF-8.
pub fn render_json(project: &ExportProject) -> anyhow::Result<String> {
    let mut json = serde_json::to_string_pretty(project)?;
    json.push('\n');
    Ok(json)
}
