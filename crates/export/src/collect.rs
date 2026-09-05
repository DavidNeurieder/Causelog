//! Collection: the only code that talks to storage. An [`ExportSource`] is a
//! minimal query surface (implemented by the server's repository) and
//! [`collect`] assembles a fully populated [`ExportProject`] from it, with
//! stable, deterministic ordering.

use std::collections::HashMap;

use async_trait::async_trait;
use causelog_model::{Decision, Experiment, ExperimentEvent, Goal, Link, Note, Project, Revision};
use uuid::Uuid;

use crate::model::{ExportDecision, ExportProject, ExportRevision};

/// Storage surface the exporter needs. Implemented for the server's SQLite
/// repository in the `causelog-server` crate, so the exporter stays free of
/// any particular backend.
#[async_trait]
pub trait ExportSource: Send + Sync {
    async fn find_project(&self, id: Uuid) -> anyhow::Result<Option<Project>>;
    async fn list_projects(&self) -> anyhow::Result<Vec<Project>>;
    async fn list_goals(&self, project_id: Uuid) -> anyhow::Result<Vec<Goal>>;
    async fn list_decisions(&self, project_id: Uuid) -> anyhow::Result<Vec<Decision>>;
    async fn list_experiments(&self, project_id: Uuid) -> anyhow::Result<Vec<Experiment>>;
    async fn list_events(&self, experiment_id: Uuid) -> anyhow::Result<Vec<ExperimentEvent>>;
    async fn list_notes(&self, project_id: Uuid) -> anyhow::Result<Vec<Note>>;
    async fn list_revisions(
        &self,
        entity_type: &str,
        entity_id: Uuid,
    ) -> anyhow::Result<Vec<Revision>>;
    async fn list_links(&self, project_id: Uuid) -> anyhow::Result<Vec<Link>>;
    async fn decision_knowledge_states(
        &self,
        project_id: Uuid,
    ) -> anyhow::Result<HashMap<Uuid, String>>;
}

/// Deterministic sort order for every entity list in an export: oldest first,
/// ties broken by id so a given database always exports the same bytes.
fn by_stable_order<T>(items: Vec<T>, key: impl Fn(&T) -> (i64, Uuid)) -> Vec<T> {
    let mut items = items;
    items.sort_by_key(key);
    items
}

/// Assemble the complete [`ExportProject`] for one project.
pub async fn collect(source: &dyn ExportSource, project_id: Uuid) -> anyhow::Result<ExportProject> {
    let project = source
        .find_project(project_id)
        .await?
        .ok_or_else(|| anyhow::anyhow!("project {project_id} not found"))?;

    let exported_at_ms = causelog_content::now_ms();
    let mut out = ExportProject::new(project, exported_at_ms, env!("CARGO_PKG_VERSION"));

    out.goals = by_stable_order(source.list_goals(project_id).await?, |g| {
        (g.created_at_ms, g.id)
    });

    let decisions = source.list_decisions(project_id).await?;
    let states = source.decision_knowledge_states(project_id).await?;
    out.decisions = by_stable_order(decisions, |d| (d.created_at_ms, d.id))
        .into_iter()
        .map(|d| ExportDecision {
            id: d.id,
            project_id: d.project_id,
            goal_id: d.goal_id,
            title: d.title,
            context: d.context,
            options: d.options,
            status: d.status,
            decided_option: d.decided_option,
            rationale: d.rationale,
            decided_at_ms: d.decided_at_ms,
            review_at_ms: d.review_at_ms,
            created_by: d.created_by,
            created_at_ms: d.created_at_ms,
            updated_at_ms: d.updated_at_ms,
            state: states.get(&d.id).cloned(),
        })
        .collect();

    let experiments = by_stable_order(source.list_experiments(project_id).await?, |e| {
        (e.created_at_ms, e.id)
    });
    out.experiments = experiments;

    out.notes = by_stable_order(source.list_notes(project_id).await?, |n| {
        (n.created_at_ms, n.id)
    });

    out.links = by_stable_order(source.list_links(project_id).await?, |l| {
        (l.created_at_ms, l.id)
    });

    for d in &out.decisions {
        out.revisions.extend(
            source
                .list_revisions("decision", d.id)
                .await?
                .into_iter()
                .map(export_revision),
        );
    }
    for n in &out.notes {
        out.revisions.extend(
            source
                .list_revisions("note", n.id)
                .await?
                .into_iter()
                .map(export_revision),
        );
    }
    out.revisions = by_stable_order(std::mem::take(&mut out.revisions), |r: &ExportRevision| {
        (r.created_at_ms, r.id)
    });

    for e in &out.experiments {
        out.events.extend(source.list_events(e.id).await?);
    }
    out.events = by_stable_order(std::mem::take(&mut out.events), |ev: &ExperimentEvent| {
        (ev.at_ms, ev.id)
    });

    Ok(out)
}

fn export_revision(r: Revision) -> ExportRevision {
    ExportRevision {
        id: r.id,
        entity_type: r.entity_type,
        entity_id: r.entity_id,
        snapshot: r.snapshot,
        created_by: r.created_by,
        created_at_ms: r.created_at_ms,
    }
}

/// Resolve a CLI project reference (a UUID or an exact, case-insensitive
/// title) to a project, or return a helpful error. Version `EXPORT_VERSION`
/// is referenced here to keep the const semantically tied to collection.
pub async fn resolve_project(
    source: &dyn ExportSource,
    reference: &str,
) -> anyhow::Result<Project> {
    if let Ok(id) = Uuid::parse_str(reference) {
        if let Some(project) = source.find_project(id).await? {
            return Ok(project);
        }
        anyhow::bail!("no project with id {reference}");
    }
    let needle = reference.to_lowercase();
    let mut matches: Vec<Project> = source
        .list_projects()
        .await?
        .into_iter()
        .filter(|p| p.title.to_lowercase() == needle)
        .collect();
    match matches.len() {
        0 => anyhow::bail!("no project called {reference:?} — pass a project id or exact title"),
        1 => Ok(matches.remove(0)),
        _ => anyhow::bail!("multiple projects match {reference:?}; pass an id instead"),
    }
}
