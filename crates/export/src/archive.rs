//! Archive export: everything a project bundle needs in one deterministic ZIP.
//!
//! The archive bundles the canonical JSON snapshot plus the generated Markdown
//! tree (and the offline HTML site's assets when present) under a
//! [`Manifest`], giving the obvious "download project" artifact.
//!
//! ```text
//! causelog-<slug>-<exported-at>.zip
//! ├── manifest.json
//! ├── project.json
//! ├── README.md
//! ├── timeline.md
//! ├── relationships.md
//! ├── goals/ decisions/ experiments/ notes/
//! └── assets/   (HTML site assets, when present)
//! ```

use serde::{Deserialize, Serialize};
use zip::write::SimpleFileOptions;

use crate::ExportFile;
use crate::model::{ExportProject, slugify};

/// Envelope identifier for an archive bundle.
pub const ARCHIVE_FORMAT: &str = "causelog-archive";
/// Current archive format version. Bump whenever the manifest changes.
pub const ARCHIVE_VERSION: u32 = 1;

/// The archive manifest: what is in the bundle and how to read it.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Manifest {
    pub format: String,
    pub version: u32,
    pub exported_at_ms: i64,
    pub causelog_version: String,
    pub project: ManifestProject,
    /// Every entry in the archive, in insertion (deterministic) order.
    pub files: Vec<ManifestFile>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ManifestProject {
    pub id: uuid::Uuid,
    pub title: String,
    pub slug: String,
}

/// One file in the archive.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ManifestFile {
    /// Path within the archive, `/`-separated.
    pub path: String,
    /// `json` | `markdown` | `html` | `text`
    pub format: String,
}

/// Bundle a project export into a deterministic ZIP archive.
///
/// `markdown` and `html` are the renderers' output (use the _path_ as the ZIP
/// entry name); only the JSON itself is added automatically.
pub fn archive(export: &ExportProject, markdown: &[ExportFile], html: &[ExportFile]) -> Vec<u8> {
    let json = crate::json::render_json(export).expect("serializing the export cannot fail");
    let slug = slugify(&export.project.title);

    let mut entries = vec![
        ExportFile {
            path: "project.json".into(),
            content: json,
        },
        ExportFile {
            path: "manifest.json".into(),
            content: String::new(), // filled below, kept first for determinism
        },
    ];
    entries.extend_from_slice(markdown);
    entries.extend_from_slice(html);

    let manifest = Manifest {
        format: ARCHIVE_FORMAT.into(),
        version: ARCHIVE_VERSION,
        exported_at_ms: export.exported_at_ms,
        causelog_version: export.causelog_version.clone(),
        project: ManifestProject {
            id: export.project.id,
            title: export.project.title.clone(),
            slug,
        },
        files: entries
            .iter()
            .map(|f| ManifestFile {
                path: f.path.clone(),
                format: manifest_format(&f.path),
            })
            .collect(),
    };
    entries[1].content = serde_json::to_string_pretty(&manifest).expect("manifest serializes");

    zip_files(&entries)
}

/// Renderer output → manifest `format` label.
fn manifest_format(path: &str) -> String {
    if path.ends_with(".json") {
        "json".into()
    } else if path.ends_with(".html") {
        "html".into()
    } else if path.ends_with(".md") {
        "markdown".into()
    } else {
        "text".into()
    }
}

/// Pack an arbitrary set of files into one deterministic ZIP: entries written
/// in input order, same options for every file, no timestamps.
pub fn zip_files(files: &[ExportFile]) -> Vec<u8> {
    let mut buf = std::io::Cursor::new(Vec::new());
    {
        let mut writer = zip::ZipWriter::new(&mut buf);
        let options = SimpleFileOptions::default()
            .compression_method(zip::CompressionMethod::Deflated)
            .unix_permissions(0o644);
        for file in files {
            writer
                .start_file(&file.path, options)
                .expect("zip entry starts");
            std::io::Write::write_all(&mut writer, file.content.as_bytes()).expect("file written");
        }
        writer.finish().expect("zip finished");
    }
    buf.into_inner()
}
