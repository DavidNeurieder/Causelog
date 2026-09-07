//! Markdown renderer: a Git-friendly directory of files, one page per entity
//! with stable frontmatter. Bodies are the original Markdown verbatim, so the
//! export is lossless, diffable and re-importable later.

use causelog_content::format_date_ms;

use crate::ExportFile;
use crate::model::{ExportProject, file_stem};
use crate::{ProjectStory, story_chain};

pub const ENTITY_DIRS: &[(&str, &str)] = &[
    ("goal", "goals"),
    ("decision", "decisions"),
    ("experiment", "experiments"),
    ("note", "notes"),
];

pub(crate) fn dir_of(entity_type: &str) -> &'static str {
    ENTITY_DIRS
        .iter()
        .find(|(t, _)| *t == entity_type)
        .map(|(_, dir)| *dir)
        .unwrap_or("misc")
}

fn path_in(root_dir: &str, dir: &str, stem: &str) -> String {
    if root_dir == dir {
        format!("{stem}.md")
    } else if root_dir.is_empty() {
        format!("{dir}/{stem}.md")
    } else {
        format!("../{dir}/{stem}.md")
    }
}

fn href(root_dir: &str, entity_type: &str, title: &str, id: uuid::Uuid) -> String {
    path_in(root_dir, dir_of(entity_type), &file_stem(title, id))
}

/// Render the whole project as a tree of Markdown files.
///
/// `story` is the **configured** [`ProjectStory`] (see
/// `build_story_with_config`): the README's story and current-state sections
/// come from it, so excluded content is never resurrected. Entity files
/// themselves stay lossless.
pub fn render_markdown(project: &ExportProject, story: &ProjectStory) -> Vec<ExportFile> {
    let mut files = Vec::new();
    files.push(ExportFile {
        path: "README.md".into(),
        content: readme(project, story),
    });
    files.push(ExportFile {
        path: "timeline.md".into(),
        content: timeline_md(project),
    });
    files.push(ExportFile {
        path: "relationships.md".into(),
        content: relationships_md(project, ""),
    });

    for g in &project.goals {
        files.push(ExportFile {
            path: path_in("", "goals", &file_stem(&g.title, g.id)),
            content: goal_md(project, g),
        });
    }
    for d in &project.decisions {
        files.push(ExportFile {
            path: path_in("", "decisions", &file_stem(&d.title, d.id)),
            content: decision_md(project, d),
        });
    }
    for e in &project.experiments {
        files.push(ExportFile {
            path: path_in("", "experiments", &file_stem(&e.title, e.id)),
            content: experiment_md(project, e),
        });
    }
    for n in &project.notes {
        files.push(ExportFile {
            path: path_in("", "notes", &file_stem(&n.title, n.id)),
            content: note_md(project, n),
        });
    }
    files
}

fn frontmatter(fields: &[(&str, String)]) -> String {
    let mut out = String::from("---\n");
    for (key, value) in fields {
        out.push_str(&format!("{key}: {value}\n"));
    }
    out.push_str("---\n");
    out
}

fn date(ms: i64) -> String {
    format_date_ms(ms)
}

fn readme(project: &ExportProject, story: &ProjectStory) -> String {
    let p = &project.project;
    let mut out = String::new();

    let states = story_state_tally(story);
    let state_line = if states.is_empty() {
        String::new()
    } else {
        format!(": {}\n", state_summary(&states))
    };

    let state_block = if state_line.is_empty() {
        String::new()
    } else {
        format!("\nCurrent state{}\n", state_line)
    };

    out.push_str(&format!(
        "# {}\n\n{}\n\n- status: {}\n- created: {}\n- updated: {}\n- exported: {}\n- format: {} v{}\n{}",
        p.title,
        if p.summary.is_empty() {
            "_no summary_".to_string()
        } else {
            p.summary.clone()
        },
        p.status,
        date(p.created_at_ms),
        date(p.updated_at_ms),
        date(project.exported_at_ms),
        project.format,
        project.version,
        state_block,
    ));

    if !project.goals.is_empty() {
        out.push_str("\n## Goals\n\n");
        for g in &project.goals {
            out.push_str(&format!(
                "- [{}]({}) — {}\n",
                g.title,
                href("", "goal", &g.title, g.id),
                g.status
            ));
        }
    }
    if !project.decisions.is_empty() {
        out.push_str("\n## Decisions\n\n");
        for d in &project.decisions {
            let state = d.state.as_deref().unwrap_or("");
            out.push_str(&format!(
                "- [{}]({}) — {} {}\n",
                d.title,
                href("", "decision", &d.title, d.id),
                d.status,
                if state.is_empty() {
                    String::new()
                } else {
                    format!("`{}`", state)
                }
            ));
        }
    }
    if !project.experiments.is_empty() {
        out.push_str("\n## Experiments\n\n");
        for e in &project.experiments {
            out.push_str(&format!(
                "- [{}]({}) — {}\n",
                e.title,
                href("", "experiment", &e.title, e.id),
                e.status
            ));
        }
    }
    if !project.notes.is_empty() {
        out.push_str("\n## Notes\n\n");
        for n in &project.notes {
            out.push_str(&format!(
                "- [{}]({}) — noted {}\n",
                n.title,
                href("", "note", &n.title, n.id),
                date(n.created_at_ms)
            ));
        }
    }

    out.push_str("\n## Story\n\n");
    let chain = story_chain(story);
    if chain.is_empty() {
        out.push_str("_Nothing here yet._\n");
    } else {
        for entry in chain {
            let link = href("", entry.kind, &entry.title, entry.id);
            let tag = if entry.tag.is_empty() {
                String::new()
            } else {
                format!(" `{}`", entry.tag)
            };
            out.push_str(&format!(
                "- `{kind}` **{title}**{tag} — [open]({link})\n",
                kind = entry.kind,
                title = entry.title,
            ));
        }
    }

    out.push_str("\n## Problem\n\n");
    let problem = story.problem.as_deref();
    match problem {
        Some(p) if !p.trim().is_empty() => out.push_str(&format!("{}\n", p)),
        _ => out.push_str("_No problem statement yet._\n"),
    }

    out.push_str("\n## Timeline\n\n");
    let timeline = crate::timeline::derive_timeline(project);
    if timeline.is_empty() {
        out.push_str("_No events yet._\n");
    } else {
        for ev in timeline {
            out.push_str(&format!(
                "- {} — {} ({})\n",
                date(ev.at_ms),
                ev.title,
                ev.kind
            ));
        }
        out.push_str("\nSee [timeline.md](timeline.md) for details.\n");
    }

    if !project.links.is_empty() {
        out.push_str(&format!(
            "\n## Relationships\n\nSee [relationships.md](relationships.md) ({} links).\n",
            project.links.len()
        ));
    }
    out
}

/// Knowledge-state tally of the decisions in the **configured** story, sorted
/// ascending by state label. Only decisions that survived configuration appear.
fn story_state_tally(story: &ProjectStory) -> Vec<(String, usize)> {
    let mut counts: std::collections::HashMap<&str, usize> = std::collections::HashMap::new();
    for d in &story.key_decisions {
        if !d.state.is_empty() {
            *counts.entry(d.state.as_str()).or_insert(0) += 1;
        }
    }
    let mut out: Vec<(String, usize)> = counts
        .into_iter()
        .map(|(k, v)| (k.to_string(), v))
        .collect();
    out.sort();
    out
}

fn state_summary(states: &[(String, usize)]) -> String {
    states
        .iter()
        .map(|(k, v)| format!("{v} {k}"))
        .collect::<Vec<_>>()
        .join(", ")
}

fn goal_md(_project: &ExportProject, g: &causelog_model::Goal) -> String {
    let mut out = frontmatter(&[
        ("type", "goal".into()),
        ("id", g.id.to_string()),
        ("status", g.status.clone()),
        ("created", date(g.created_at_ms)),
        ("updated", date(g.updated_at_ms)),
    ]);
    out.push_str(&format!("\n# {}\n\n{}", g.title, g.body));
    out
}

fn decision_md(project: &ExportProject, d: &crate::model::ExportDecision) -> String {
    let state = d.state.clone().unwrap_or_default();
    let mut out = frontmatter(&[
        ("type", "decision".into()),
        ("id", d.id.to_string()),
        ("status", d.status.clone()),
        ("state", state),
        ("created", date(d.created_at_ms)),
        ("updated", date(d.updated_at_ms)),
    ]);
    out.push_str(&format!("\n# {}\n\n", d.title));
    if !d.context.trim().is_empty() {
        out.push_str(&format!("## Context\n\n{}\n\n", d.context));
    }
    if !d.options.is_empty() {
        out.push_str("## Options\n\n");
        for o in &d.options {
            let chosen = if Some(&o.id) == d.decided_option.as_ref() {
                " _(chosen)_"
            } else {
                ""
            };
            out.push_str(&format!("### {}{}\n\n", o.label, chosen));
            if !o.pros.trim().is_empty() {
                out.push_str(&format!("**Pros:**\n\n{}\n\n", o.pros));
            }
            if !o.cons.trim().is_empty() {
                out.push_str(&format!("**Cons:**\n\n{}\n\n", o.cons));
            }
        }
    }
    if !d.rationale.trim().is_empty() {
        out.push_str(&format!("## Rationale\n\n{}\n\n", d.rationale));
    }
    if let Some(at) = d.decided_at_ms {
        out.push_str(&format!("\n_Decided on {}._\n", date(at)));
    }
    if let Some(at) = d.review_at_ms {
        out.push_str(&format!("\n_Review by {}._\n", date(at)));
    }
    if let Some(goal) = d
        .goal_id
        .and_then(|id| project.goals.iter().find(|g| g.id == id))
    {
        out.push_str(&format!(
            "\n## Related\n\n- [Goal: {}]({})\n",
            goal.title,
            href("decisions", "goal", &goal.title, goal.id)
        ));
    }
    if let Some(state) = d.state.as_deref() {
        out.push_str(&format!("\n_Knowledge state: {state}_\n"));
    }
    out.push_str(&references_for(project, "decision", d.id, "decisions"));
    out
}

fn experiment_md(project: &ExportProject, e: &causelog_model::Experiment) -> String {
    let mut out = frontmatter(&[
        ("type", "experiment".into()),
        ("id", e.id.to_string()),
        ("status", e.status.clone()),
        ("created", date(e.created_at_ms)),
        ("updated", date(e.updated_at_ms)),
    ]);
    out.push_str(&format!("# {}\n\n", e.title));
    if !e.hypothesis.trim().is_empty() {
        out.push_str(&format!("## Hypothesis\n\n{}\n\n", e.hypothesis));
    }
    if let Some(started) = e.started_at_ms {
        out.push_str(&format!("- started: {}\n", date(started)));
    }
    if let Some(ended) = e.ended_at_ms {
        out.push_str(&format!("- ended: {}\n", date(ended)));
    }
    let events: Vec<_> = project
        .events
        .iter()
        .filter(|ev| ev.experiment_id == e.id)
        .collect();
    if !events.is_empty() {
        out.push_str("\n## Events\n\n");
        for ev in &events {
            out.push_str(&format!(
                "- {} `{}` — {}\n",
                date(ev.at_ms),
                ev.kind,
                ev.note.trim().replace('\n', " ")
            ));
        }
    }
    if !e.result.trim().is_empty() {
        out.push_str(&format!("\n## Result\n\n{}\n", e.result));
    }
    if !e.lesson.trim().is_empty() {
        out.push_str(&format!("\n## Lesson\n\n{}\n", e.lesson));
    }
    if let Some(goal) = e
        .goal_id
        .and_then(|id| project.goals.iter().find(|g| g.id == id))
    {
        out.push_str(&format!(
            "\n## Related\n\n- [Goal: {}]({})\n",
            goal.title,
            href("experiments", "goal", &goal.title, goal.id)
        ));
    }
    if let Some(decision) = e
        .decision_id
        .and_then(|id| project.decisions.iter().find(|d| d.id == id))
    {
        out.push_str(&format!(
            "- [Decision: {}]({})\n",
            decision.title,
            href("experiments", "decision", &decision.title, decision.id)
        ));
    }
    out.push_str(&references_for(project, "experiment", e.id, "experiments"));
    out
}

fn note_md(project: &ExportProject, n: &causelog_model::Note) -> String {
    let mut out = frontmatter(&[
        ("type", "note".into()),
        ("id", n.id.to_string()),
        ("created", date(n.created_at_ms)),
        ("updated", date(n.updated_at_ms)),
    ]);
    out.push_str(&format!("\n# {}\n\n{}", n.title, n.body));
    if let (Some(source_type), Some(source_id)) = (n.source_type.as_deref(), n.source_id) {
        let label = match source_type {
            "experiment" => project
                .experiments
                .iter()
                .find(|e| e.id == source_id)
                .map(|e| e.title.clone()),
            "decision" => project
                .decisions
                .iter()
                .find(|d| d.id == source_id)
                .map(|d| d.title.clone()),
            _ => None,
        };
        if let Some(title) = label {
            out.push_str(&format!(
                "\n## Related\n\n- _Captured from [{}: {}]({})_\n",
                source_type,
                title,
                href("notes", source_type, &title, source_id)
            ));
        }
    }
    out
}

/// A `## Linked entities` cross-reference block for explicit links touching an
/// entity (both directions), so a decision page points at the experiment that
/// validated it and vice versa.
fn references_for(
    project: &ExportProject,
    self_type: &str,
    self_id: uuid::Uuid,
    self_dir: &str,
) -> String {
    let mut related: Vec<(String, String, String, uuid::Uuid)> = Vec::new();
    for l in &project.links {
        if l.from_type == self_type
            && l.from_id == self_id
            && let Some((title, dir, to_id)) = entity_label(project, &l.to_type, l.to_id)
        {
            related.push((format!("→ {} ({})", l.to_type, l.kind), title, dir, to_id));
        }
        if l.to_type == self_type
            && l.to_id == self_id
            && let Some((title, dir, from_id)) = entity_label(project, &l.from_type, l.from_id)
        {
            related.push((
                format!("← {} ({})", l.from_type, l.kind),
                title,
                dir,
                from_id,
            ));
        }
    }
    related.sort_by(|a, b| a.1.cmp(&b.1));
    if related.is_empty() {
        return String::new();
    }
    let mut out = "\n## Linked entities\n\n".to_string();
    for (label, title, dir, id) in related {
        let link = path_in(self_dir, &dir, &file_stem(&title, id));
        out.push_str(&format!("- {label}: [{}]({link})\n", title));
    }
    out
}

fn entity_label(
    project: &ExportProject,
    entity_type: &str,
    id: uuid::Uuid,
) -> Option<(String, String, uuid::Uuid)> {
    let found: Option<(String, uuid::Uuid)> = match entity_type {
        "goal" => project
            .goals
            .iter()
            .find(|g| g.id == id)
            .map(|g| (g.title.clone(), g.id)),
        "decision" => project
            .decisions
            .iter()
            .find(|d| d.id == id)
            .map(|d| (d.title.clone(), d.id)),
        "experiment" => project
            .experiments
            .iter()
            .find(|e| e.id == id)
            .map(|e| (e.title.clone(), e.id)),
        "note" => project
            .notes
            .iter()
            .find(|n| n.id == id)
            .map(|n| (n.title.clone(), n.id)),
        _ => None,
    };
    let (title, entity_id) = found?;
    Some((title, dir_of(entity_type).to_string(), entity_id))
}

fn timeline_md(project: &ExportProject) -> String {
    let mut out = String::from("# Timeline\n\n");
    let timeline = crate::timeline::derive_timeline(project);
    if timeline.is_empty() {
        out.push_str("_No events yet._\n");
        return out;
    }
    for ev in &timeline {
        out.push_str(&format!("## {} — {}\n\n", date(ev.at_ms), ev.title));
        out.push_str(&format!("- kind: `{}`\n", ev.kind));
        if !ev.detail.trim().is_empty() {
            out.push_str(&format!(
                "- detail: {}\n",
                ev.detail.trim().replace('\n', " ")
            ));
        }
        // Best-effort link to the entity if the title matches something.
        out.push('\n');
    }
    out
}

fn relationships_md(project: &ExportProject, _root_dir: &str) -> String {
    let mut out = String::from("# Relationships\n\n");
    if project.links.is_empty() {
        out.push_str("_No explicit links yet._\n");
        return out;
    }
    out.push_str("```\n");
    for l in &project.links {
        let from = entity_label(project, &l.from_type, l.from_id)
            .map(|(t, _, _)| format!("{}:{t}", l.from_type))
            .unwrap_or(format!("{}:{}", l.from_type, l.from_id));
        let to = entity_label(project, &l.to_type, l.to_id)
            .map(|(t, _, _)| format!("{}:{t}", l.to_type))
            .unwrap_or(format!("{}:{}", l.to_type, l.to_id));
        out.push_str(&format!("{from} --{kind}--> {to}\n", kind = l.kind));
    }
    out.push_str("```\n");
    out
}
