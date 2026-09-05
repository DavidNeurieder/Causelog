//! Offline static HTML site renderer. Every page is a complete, self-contained
//! document; assets are bundled into `assets/styles.css`, there are no CDN or
//! external references, and all links are relative so the export can be
//! dropped onto any static host or opened from disk.

use causelog_content::render_markdown;
use causelog_model::{Experiment, Goal, Note};

use crate::ExportFile;
use crate::model::{ExportProject, file_stem};

const CSS: &str = include_str!("../static/export.css");

fn dir_of(entity_type: &str) -> &'static str {
    crate::markdown::dir_of(entity_type)
}

fn html_path(root_dir: &str, dir: &str, stem: &str) -> String {
    if root_dir == dir {
        format!("{stem}.html")
    } else if root_dir.is_empty() {
        format!("{dir}/{stem}.html")
    } else {
        format!("../{dir}/{stem}.html")
    }
}

fn href(root_dir: &str, entity_type: &str, title: &str, id: uuid::Uuid) -> String {
    html_path(root_dir, dir_of(entity_type), &file_stem(title, id))
}

fn esc(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for ch in s.chars() {
        match ch {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            '\'' => out.push_str("&#39;"),
            _ => out.push(ch),
        }
    }
    out
}

fn date(ms: i64) -> String {
    causelog_content::format_date_ms(ms)
}

/// Render the whole project as an offline static site.
pub fn render_html(project: &ExportProject) -> Vec<ExportFile> {
    let css_file = ExportFile {
        path: "assets/styles.css".into(),
        content: CSS.to_string(),
    };

    let title = esc(&project.project.title);
    let mut files = vec![css_file];

    let nav = nav("", "");
    files.push(ExportFile {
        path: "index.html".into(),
        content: page(&title, &nav, index_body(project), "index"),
    });
    files.push(ExportFile {
        path: "timeline.html".into(),
        content: page(
            &format!("Timeline · {title}"),
            &nav,
            timeline_body(project),
            "timeline",
        ),
    });
    files.push(ExportFile {
        path: "relationships.html".into(),
        content: page(
            &format!("Relationships · {title}"),
            &nav,
            relationships_body(project),
            "relationships",
        ),
    });

    for g in &project.goals {
        files.push(ExportFile {
            path: html_path("", "goals", &file_stem(&g.title, g.id)),
            content: goal_page(project, g),
        });
    }
    for d in &project.decisions {
        files.push(ExportFile {
            path: html_path("", "decisions", &file_stem(&d.title, d.id)),
            content: decision_page(project, d),
        });
    }
    for e in &project.experiments {
        files.push(ExportFile {
            path: html_path("", "experiments", &file_stem(&e.title, e.id)),
            content: experiment_page(project, e),
        });
    }
    for n in &project.notes {
        files.push(ExportFile {
            path: html_path("", "notes", &file_stem(&n.title, n.id)),
            content: note_page(project, n),
        });
    }
    files
}

/// Relative navigation links for a page in `dir` (`""` for the root).
fn nav(dir: &str, active: &str) -> Vec<(String, String, bool)> {
    let mut items = Vec::new();
    for (label, target, key) in [
        ("Project", "index.html", "index"),
        ("Goals", "goals/", "goals"),
        ("Decisions", "decisions/", "decisions"),
        ("Experiments", "experiments/", "experiments"),
        ("Notes", "notes/", "notes"),
        ("Timeline", "timeline.html", "timeline"),
        ("Relationships", "relationships.html", "relationships"),
    ] {
        let href = if dir.is_empty() {
            target.to_string()
        } else {
            format!("../{target}")
        };
        items.push((label.to_string(), href, active == key));
    }
    items
}

fn nav_html(nav: &[(String, String, bool)]) -> String {
    if nav.is_empty() {
        return String::new();
    }
    let mut out = String::from("<nav class=\"nav\"><ul>");
    for (label, href, on) in nav {
        let cls = if *on { " class=\"on\"" } else { "" };
        out.push_str(&format!(
            "<li><a{cls} href=\"{}\">{}</a></li>\n",
            esc(href),
            esc(label)
        ));
    }
    out.push_str("</ul></nav>");
    out
}

fn page(title: &str, nav: &[(String, String, bool)], body: String, _active: &str) -> String {
    let mut out = String::from("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n");
    out.push_str("<meta charset=\"utf-8\">\n");
    out.push_str("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n");
    out.push_str(&format!("<title>{title}</title>\n"));
    out.push_str("<link rel=\"stylesheet\" href=\"assets/styles.css\">\n");
    out.push_str("</head>\n<body>\n");
    out.push_str(&nav_html(nav));
    out.push_str(&body);
    out.push_str("<footer class=\"footer\">Exported from Causelog · markdown-envelope</footer>\n");
    out.push_str("</body>\n</html>\n");
    out
}

fn sections(blocks: Vec<(String, String)>) -> String {
    let mut out = String::new();
    for (heading, html) in blocks {
        out.push_str(&format!(
            "<section class=\"panel\"><h2>{}</h2>{}</section>\n",
            esc(&heading),
            html
        ));
    }
    out
}

fn index_body(project: &ExportProject) -> String {
    let p = &project.project;
    let mut blocks = Vec::new();

    let summary = if p.summary.trim().is_empty() {
        "<p class=\"muted\">No summary.</p>".to_string()
    } else {
        render_markdown(&p.summary)
    };
    blocks.push(("Summary".into(), summary));

    let states = tally_states(project);
    let chips = if states.is_empty() {
        "<p class=\"muted\">No decided decisions yet.</p>".to_string()
    } else {
        states
            .iter()
            .map(|(k, v)| format!("<span class=\"tag state-{k}\">{v} {k}</span>"))
            .collect::<Vec<_>>()
            .join("\n")
    };
    blocks.push((
        "Current state".into(),
        format!("<div class=\"chips\">{chips}</div>"),
    ));

    let story = story_chain_html(project, "");
    let story_html = if story.is_empty() {
        "<p class=\"muted\">Nothing here yet.</p>".to_string()
    } else {
        let mut out = String::from("<ol class=\"story\">\n");
        for (kind, title, link, tag) in story {
            let tag_html = if tag.is_empty() {
                String::new()
            } else {
                format!(" <span class=\"tag state-{tag}\">{tag}</span>")
            };
            out.push_str(&format!(
                "<li class=\"story-{kind}\"><span class=\"mark\">{kind}</span> <a href=\"{link}\">{}</a>{}</li>\n",
                esc(&title),
                tag_html
            ));
        }
        out.push_str("</ol>\n");
        out
    };
    blocks.push(("Story".into(), story_html));

    blocks.push(("Goals".into(), list_goals(project, "")));
    blocks.push(("Decisions".into(), list_decisions(project, "")));
    blocks.push(("Experiments".into(), list_experiments(project, "")));
    blocks.push(("Notes".into(), list_notes(project, "")));

    format!(
        "<header class=\"masthead\"><h1>{}</h1><p class=\"muted\">{}</p>\
         <p class=\"meta\">status: {} · created {} · updated {}</p>\
         <p class=\"meta\">{} v{} · exported {}</p></header>\n",
        esc(&p.title),
        esc(&p.status),
        esc(&p.status),
        date(p.created_at_ms),
        date(p.updated_at_ms),
        esc(&project.format),
        project.version,
        date(project.exported_at_ms),
    ) + &sections(blocks)
}

fn list_goals(project: &ExportProject, dir: &str) -> String {
    if project.goals.is_empty() {
        return "<p class=\"muted\">No goals.</p>".to_string();
    }
    let mut out = String::from("<ul class=\"list\">\n");
    for g in &project.goals {
        out.push_str(&format!(
            "<li><a href=\"{}\">{}</a> <span class=\"tag status-{}\">{}</span></li>\n",
            href(dir, "goal", &g.title, g.id),
            esc(&g.title),
            esc(&g.status),
            esc(&g.status)
        ));
    }
    out.push_str("</ul>\n");
    out
}

fn list_decisions(project: &ExportProject, dir: &str) -> String {
    if project.decisions.is_empty() {
        return "<p class=\"muted\">No decisions.</p>".to_string();
    }
    let mut out = String::from("<ul class=\"list\">\n");
    for d in &project.decisions {
        let state = d.state.as_deref().unwrap_or("");
        let state_html = if state.is_empty() {
            String::new()
        } else {
            format!(
                " <span class=\"tag state-{}\">{}</span>",
                esc(state),
                esc(state)
            )
        };
        out.push_str(&format!(
            "<li><a href=\"{}\">{}</a> <span class=\"tag status-{}\">{}</span>{}</li>\n",
            href(dir, "decision", &d.title, d.id),
            esc(&d.title),
            esc(&d.status),
            esc(&d.status),
            state_html
        ));
    }
    out.push_str("</ul>\n");
    out
}

fn list_experiments(project: &ExportProject, dir: &str) -> String {
    if project.experiments.is_empty() {
        return "<p class=\"muted\">No experiments.</p>".to_string();
    }
    let mut out = String::from("<ul class=\"list\">\n");
    for e in &project.experiments {
        out.push_str(&format!(
            "<li><a href=\"{}\">{}</a> <span class=\"tag status-{}\">{}</span></li>\n",
            href(dir, "experiment", &e.title, e.id),
            esc(&e.title),
            esc(&e.status),
            esc(&e.status)
        ));
    }
    out.push_str("</ul>\n");
    out
}

fn list_notes(project: &ExportProject, dir: &str) -> String {
    if project.notes.is_empty() {
        return "<p class=\"muted\">No notes.</p>".to_string();
    }
    let mut out = String::from("<ul class=\"list\">\n");
    for n in &project.notes {
        out.push_str(&format!(
            "<li><a href=\"{}\">{}</a> <span class=\"muted\">noted {}</span></li>\n",
            href(dir, "note", &n.title, n.id),
            esc(&n.title),
            date(n.created_at_ms)
        ));
    }
    out.push_str("</ul>\n");
    out
}

fn story_chain_html(project: &ExportProject, dir: &str) -> Vec<(String, String, String, String)> {
    let mut all: Vec<(i64, String, String, uuid::Uuid)> = Vec::new();
    for g in &project.goals {
        all.push((g.created_at_ms, "goal".into(), g.title.clone(), g.id));
    }
    for d in &project.decisions {
        all.push((d.created_at_ms, "decision".into(), d.title.clone(), d.id));
    }
    for e in &project.experiments {
        all.push((e.created_at_ms, "experiment".into(), e.title.clone(), e.id));
    }
    for n in &project.notes {
        all.push((n.created_at_ms, "note".into(), n.title.clone(), n.id));
    }
    all.sort_by_key(|(t, kind, title, id)| (*t, kind.clone(), title.clone(), *id));
    all.into_iter()
        .map(|(_, kind, title, id)| {
            let link = href(dir, &kind, &title, id);
            let tag = if kind == "decision" {
                project
                    .decisions
                    .iter()
                    .find(|d| d.id == id)
                    .and_then(|d| d.state.clone())
                    .unwrap_or_default()
            } else {
                String::new()
            };
            (kind, title, link, tag)
        })
        .collect()
}

fn tally_states(project: &ExportProject) -> Vec<(String, usize)> {
    let mut counts: std::collections::HashMap<&str, usize> = std::collections::HashMap::new();
    for d in &project.decisions {
        if let Some(state) = d.state.as_deref() {
            *counts.entry(state).or_insert(0) += 1;
        }
    }
    let mut out: Vec<(String, usize)> = counts
        .into_iter()
        .map(|(k, v)| (k.to_string(), v))
        .collect();
    out.sort();
    out
}

fn goal_page(project: &ExportProject, g: &Goal) -> String {
    let title = format!("{} · {}", g.title, project.project.title);
    let mut blocks = Vec::new();
    if !g.body.trim().is_empty() {
        blocks.push(("Goal".into(), render_markdown(&g.body)));
    }
    blocks.push((
        "Linked decisions".into(),
        list_related(project, "goal", g.id),
    ));
    page(
        &esc(&title),
        &nav("goals", "goals"),
        format!(
            "<article class=\"entity\"><header class=\"masthead\"><h1>{}</h1>\
             <p class=\"meta\">goal · status {} · updated {}</p></header>\n{}</article>\n",
            esc(&g.title),
            esc(&g.status),
            date(g.updated_at_ms),
            sections(blocks)
        ),
        "goals",
    )
}

fn decision_page(project: &ExportProject, d: &crate::model::ExportDecision) -> String {
    let title = format!("{} · {}", d.title, project.project.title);
    let mut blocks = Vec::new();
    if !d.context.trim().is_empty() {
        blocks.push(("Context".into(), render_markdown(&d.context)));
    }
    if !d.options.is_empty() {
        let mut html = String::from("<div class=\"options\">\n");
        for o in &d.options {
            let chosen = if Some(&o.id) == d.decided_option.as_ref() {
                " chosen"
            } else {
                ""
            };
            html.push_str(&format!(
                "<div class=\"option{chosen}\"><h3>{}</h3>",
                esc(&o.label)
            ));
            if o.pros.trim().is_empty() {
                html.push_str("<p class=\"muted\">no pros listed</p>");
            } else {
                html.push_str(
                    format!("<p><strong>Pros:</strong> {}</p>", render_markdown(&o.pros)).as_str(),
                );
            }
            if o.cons.trim().is_empty() {
                html.push_str("<p class=\"muted\">no cons listed</p>");
            } else {
                html.push_str(
                    format!("<p><strong>Cons:</strong> {}</p>", render_markdown(&o.cons)).as_str(),
                );
            }
            html.push_str("</div>\n");
        }
        html.push_str("</div>\n");
        blocks.push(("Options".into(), html));
    }
    if !d.rationale.trim().is_empty() {
        blocks.push(("Rationale".into(), render_markdown(&d.rationale)));
    }
    let mut meta = Vec::new();
    if let Some(at) = d.decided_at_ms {
        meta.push(format!("decided {}", date(at)));
    }
    if let Some(at) = d.review_at_ms {
        meta.push(format!("review by {}", date(at)));
    }
    if let Some(state) = d.state.as_deref() {
        meta.push(format!("state {state}"));
    }
    if !meta.is_empty() {
        blocks.push((
            "Meta".into(),
            format!("<p class=\"meta\">{}</p>", esc(&meta.join(" · "))),
        ));
    }
    blocks.push((
        "Linked experiments".into(),
        list_related(project, "decision", d.id),
    ));
    page(
        &esc(&title),
        &nav("decisions", "decisions"),
        format!(
            "<article class=\"entity\"><header class=\"masthead\"><h1>{}</h1>\
             <p class=\"meta\">decision · status {}</p></header>\n{}</article>\n",
            esc(&d.title),
            esc(&d.status),
            sections(blocks)
        ),
        "decisions",
    )
}

fn experiment_page(project: &ExportProject, e: &Experiment) -> String {
    let title = format!("{} · {}", e.title, project.project.title);
    let mut blocks = Vec::new();
    if !e.hypothesis.trim().is_empty() {
        blocks.push(("Hypothesis".into(), render_markdown(&e.hypothesis)));
    }
    let events: Vec<_> = project
        .events
        .iter()
        .filter(|ev| ev.experiment_id == e.id)
        .collect();
    if !events.is_empty() {
        let mut html = String::from("<ul class=\"list\">\n");
        for ev in &events {
            html.push_str(&format!(
                "<li><strong>{}</strong> <code>{}</code> — {}</li>\n",
                date(ev.at_ms),
                esc(&ev.kind),
                render_markdown(&ev.note)
            ));
        }
        html.push_str("</ul>\n");
        blocks.push(("Events".into(), html));
    }
    if !e.result.trim().is_empty() {
        blocks.push(("Result".into(), render_markdown(&e.result)));
    }
    if !e.lesson.trim().is_empty() {
        blocks.push(("Lesson".into(), render_markdown(&e.lesson)));
    }
    blocks.push((
        "Linked entities".into(),
        list_related(project, "experiment", e.id),
    ));
    page(
        &esc(&title),
        &nav("experiments", "experiments"),
        format!(
            "<article class=\"entity\"><header class=\"masthead\"><h1>{}</h1>\
             <p class=\"meta\">experiment · status {} · updated {}</p></header>\n{}</article>\n",
            esc(&e.title),
            esc(&e.status),
            date(e.updated_at_ms),
            sections(blocks)
        ),
        "experiments",
    )
}

fn note_page(project: &ExportProject, n: &Note) -> String {
    let title = format!("{} · {}", n.title, project.project.title);
    page(
        &esc(&title),
        &nav("notes", "notes"),
        format!(
            "<article class=\"entity\"><header class=\"masthead\"><h1>{}</h1>\
             <p class=\"meta\">note · noted {}</p></header>\n{}\n</article>\n",
            esc(&n.title),
            date(n.created_at_ms),
            render_markdown(&n.body)
        ),
        "notes",
    )
}

fn timeline_body(project: &ExportProject) -> String {
    let timeline = crate::timeline::derive_timeline(project);
    if timeline.is_empty() {
        return "<p class=\"muted\">No events yet.</p>".to_string();
    }
    let mut out = String::from("<ol class=\"timeline\">\n");
    for ev in &timeline {
        let detail = if ev.detail.trim().is_empty() {
            String::new()
        } else {
            format!(" <span class=\"muted\">— {}</span>", esc(&ev.detail))
        };
        out.push_str(&format!(
            "<li><time>{}</time> <strong>{}</strong> <code>{}</code>{}</li>\n",
            date(ev.at_ms),
            esc(&ev.title),
            esc(&ev.kind),
            detail
        ));
    }
    out.push_str("</ol>\n");
    format!("<main class=\"content\"><h1>Timeline</h1>\n{out}</main>\n")
}

fn relationships_body(project: &ExportProject) -> String {
    if project.links.is_empty() {
        return "<main class=\"content\"><h1>Relationships</h1><p class=\"muted\">No explicit links yet.</p></main>\n"
            .to_string();
    }
    let mut out =
        String::from("<main class=\"content\"><h1>Relationships</h1><dl class=\"links\">\n");
    for l in &project.links {
        let from = label_or_id(project, &l.from_type, l.from_id);
        let to = label_or_id(project, &l.to_type, l.to_id);
        out.push_str(&format!(
            "<dt><code>{from}</code> --{kind}--&gt; <code>{to}</code></dt>\n",
            kind = esc(&l.kind)
        ));
    }
    out.push_str("</dl></main>\n");
    out
}

/// Linked entities touching `(self_type, self_id)` in either direction, as a
/// bullet list of links (empty string when there are none).
fn list_related(project: &ExportProject, self_type: &str, self_id: uuid::Uuid) -> String {
    let mut related: Vec<(String, String, uuid::Uuid, String)> = Vec::new();
    for l in &project.links {
        if l.from_type == self_type
            && l.from_id == self_id
            && let Some((title, dir, to_id)) = label(project, &l.to_type, l.to_id)
        {
            related.push((dir, title, to_id, format!("to {} ({})", l.to_type, l.kind)));
        }
        if l.to_type == self_type
            && l.to_id == self_id
            && let Some((title, dir, from_id)) = label(project, &l.from_type, l.from_id)
        {
            related.push((
                dir,
                title,
                from_id,
                format!("from {} ({})", l.from_type, l.kind),
            ));
        }
    }
    if related.is_empty() {
        return "<p class=\"muted\">No linked entities.</p>".to_string();
    }
    related.sort_by(|a, b| a.1.cmp(&b.1));
    let mut out = String::from("<ul class=\"list\">\n");
    for (dir, title, id, label) in related {
        out.push_str(&format!(
            "<li>{label}: <a href=\"{}\">{}</a></li>\n",
            html_path("", &dir, &file_stem(&title, id)),
            esc(&title)
        ));
    }
    out.push_str("</ul>\n");
    out
}

fn label(
    project: &ExportProject,
    entity_type: &str,
    id: uuid::Uuid,
) -> Option<(String, String, uuid::Uuid)> {
    match entity_type {
        "goal" => project
            .goals
            .iter()
            .find(|g| g.id == id)
            .map(|g| (g.title.clone(), id)),
        "decision" => project
            .decisions
            .iter()
            .find(|d| d.id == id)
            .map(|d| (d.title.clone(), id)),
        "experiment" => project
            .experiments
            .iter()
            .find(|e| e.id == id)
            .map(|e| (e.title.clone(), id)),
        "note" => project
            .notes
            .iter()
            .find(|n| n.id == id)
            .map(|n| (n.title.clone(), id)),
        _ => None,
    }
    .map(|(title, id)| (title, dir_of(entity_type).to_string(), id))
}

fn label_or_id(project: &ExportProject, entity_type: &str, id: uuid::Uuid) -> String {
    label(project, entity_type, id)
        .map(|(t, _, _)| t)
        .unwrap_or_else(|| format!("{entity_type}:{id}"))
}
