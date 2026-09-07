//! Archive (ZIP) tests: the bundle must contain the manifest, project JSON and
//! the Markdown/HTML trees, list exactly what it contains, and be
//! byte-deterministic.

use std::io::Cursor;

use causelog_export::ExportFile;
use causelog_export::ExportProject as EP;
use causelog_export::archive::{Manifest, archive};
use causelog_model::Project;
use uuid::Uuid;

fn id(s: &str) -> Uuid {
    uuid::Uuid::parse_str(s).unwrap()
}

fn export() -> EP {
    let project = Project {
        id: id("11111111-1111-1111-1111-111111111111"),
        title: "Coffee Machine Uprising".into(),
        summary: "They will not grind us down.".into(),
        status: "active".into(),
        created_by: None,
        created_at_ms: 1_700_000_000_000,
        updated_at_ms: 1_700_000_000_000,
    };
    EP::new(project, 1_700_000_100_000, "test-version")
}

fn sample_markdown() -> Vec<ExportFile> {
    vec![
        ExportFile {
            path: "README.md".into(),
            content: "# Coffee Machine Uprising\n".into(),
        },
        ExportFile {
            path: "timeline.md".into(),
            content: "# Timeline\n".into(),
        },
    ]
}

/// List the entry names inside a raw ZIP archive, in stored order.
fn zip_names(bytes: &[u8]) -> Vec<String> {
    let mut names = Vec::new();
    let mut zip = zip::ZipArchive::new(Cursor::new(bytes)).unwrap();
    for i in 0..zip.len() {
        names.push(zip.by_index(i).unwrap().name().to_string());
    }
    names
}

fn read_zip_entry(bytes: &[u8], name: &str) -> String {
    let mut zip = zip::ZipArchive::new(Cursor::new(bytes)).unwrap();
    let mut file = zip.by_name(name).unwrap();
    let mut out = String::new();
    std::io::Read::read_to_string(&mut file, &mut out).unwrap();
    out
}

#[test]
fn archive_contains_manifest_project_json_and_tree() {
    let ep = export();
    let bundle = archive(&ep, &sample_markdown(), &[]).unwrap();
    let names = zip_names(&bundle);

    for expected in ["manifest.json", "project.json", "README.md", "timeline.md"] {
        assert!(
            names.iter().any(|n| n == expected),
            "archive missing {expected}; got {names:?}"
        );
    }

    let project_json = read_zip_entry(&bundle, "project.json");
    let parsed: EP = serde_json::from_str(&project_json).unwrap();
    assert_eq!(parsed.project.title, "Coffee Machine Uprising");
    assert_eq!(parsed.format, "causelog-export");
}

#[test]
fn manifest_lists_exact_file_paths() {
    let bundle = archive(&export(), &sample_markdown(), &[]).unwrap();
    let manifest: Manifest =
        serde_json::from_str(&read_zip_entry(&bundle, "manifest.json")).unwrap();

    assert_eq!(manifest.format, "causelog-archive");
    assert_eq!(manifest.version, 1);
    assert_eq!(manifest.schema_version, 1);
    assert_eq!(manifest.project.title, "Coffee Machine Uprising");
    assert_eq!(manifest.project.slug, "coffee-machine-uprising");
    let paths: Vec<&str> = manifest.files.iter().map(|f| f.path.as_str()).collect();
    assert_eq!(
        paths,
        vec!["project.json", "manifest.json", "README.md", "timeline.md"]
    );
}

#[test]
fn archive_is_deterministic_bytes() {
    let ep = export();
    let a = archive(&ep, &sample_markdown(), &[]).unwrap();
    let b = archive(&ep, &sample_markdown(), &[]).unwrap();
    assert_eq!(a, b, "same input must produce identical archive bytes");
}

#[test]
fn archive_includes_html_assets_when_present() {
    let html = vec![ExportFile {
        path: "assets/styles.css".into(),
        content: "body { color: #000; }\n".into(),
    }];
    let bundle = archive(&export(), &sample_markdown(), &html).unwrap();
    let names = zip_names(&bundle);
    assert!(
        names.iter().any(|n| n == "assets/styles.css"),
        "archive missing html asset; got {names:?}"
    );
    assert!(read_zip_entry(&bundle, "assets/styles.css").contains("color: #000"));
}
