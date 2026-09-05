//! Adapter wiring the server's repository into the export pipeline. The
//! exporter stays backend-agnostic (it only knows [`ExportSource`]); this file
//! narrows [`SqliteRepository`] to that surface.

use async_trait::async_trait;

use crate::repository::{Repository, SqliteRepository};

/// `SqliteRepository` can be handed straight to `causelog_export::collect`.
/// Every method maps onto an existing repository query, so the export format
/// never sees storage internals. Calls are fully qualified to disambiguate the
/// two traits in scope (`Repository` and `ExportSource`).
#[async_trait]
impl causelog_export::ExportSource for SqliteRepository {
    async fn find_project(
        &self,
        id: uuid::Uuid,
    ) -> anyhow::Result<Option<causelog_model::Project>> {
        Ok(Repository::find_project(self, id).await?)
    }

    async fn list_projects(&self) -> anyhow::Result<Vec<causelog_model::Project>> {
        Ok(Repository::list_projects(self).await?)
    }

    async fn list_goals(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Goal>> {
        Ok(Repository::list_goals(self, project_id).await?)
    }

    async fn list_decisions(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Decision>> {
        Ok(Repository::list_decisions(self, project_id).await?)
    }

    async fn list_experiments(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Experiment>> {
        Ok(Repository::list_experiments(self, project_id).await?)
    }

    async fn list_events(
        &self,
        experiment_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::ExperimentEvent>> {
        Ok(Repository::list_events(self, experiment_id).await?)
    }

    async fn list_notes(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Note>> {
        Ok(Repository::list_notes(self, project_id).await?)
    }

    async fn list_revisions(
        &self,
        entity_type: &str,
        entity_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Revision>> {
        Ok(Repository::list_revisions(self, entity_type, entity_id).await?)
    }

    async fn list_links(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Link>> {
        Ok(Repository::list_links(self, project_id).await?)
    }

    async fn decision_knowledge_states(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<std::collections::HashMap<uuid::Uuid, String>> {
        Ok(Repository::decision_knowledge_states(self, project_id).await?)
    }
}

/// The web app holds its repository as a `dyn Repository` trait object, so the
/// export pipeline must accept that too (not just the concrete
/// [`SqliteRepository`]). Implemented for `&dyn Repository` (a sized, local
/// type) so callers can pass a plain borrow and let `&T → &dyn ExportSource`
/// coercion do the rest.
#[async_trait]
impl causelog_export::ExportSource for &dyn Repository {
    async fn find_project(
        &self,
        id: uuid::Uuid,
    ) -> anyhow::Result<Option<causelog_model::Project>> {
        Ok(Repository::find_project(*self, id).await?)
    }

    async fn list_projects(&self) -> anyhow::Result<Vec<causelog_model::Project>> {
        Ok(Repository::list_projects(*self).await?)
    }

    async fn list_goals(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Goal>> {
        Ok(Repository::list_goals(*self, project_id).await?)
    }

    async fn list_decisions(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Decision>> {
        Ok(Repository::list_decisions(*self, project_id).await?)
    }

    async fn list_experiments(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Experiment>> {
        Ok(Repository::list_experiments(*self, project_id).await?)
    }

    async fn list_events(
        &self,
        experiment_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::ExperimentEvent>> {
        Ok(Repository::list_events(*self, experiment_id).await?)
    }

    async fn list_notes(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Note>> {
        Ok(Repository::list_notes(*self, project_id).await?)
    }

    async fn list_revisions(
        &self,
        entity_type: &str,
        entity_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Revision>> {
        Ok(Repository::list_revisions(*self, entity_type, entity_id).await?)
    }

    async fn list_links(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<Vec<causelog_model::Link>> {
        Ok(Repository::list_links(*self, project_id).await?)
    }

    async fn decision_knowledge_states(
        &self,
        project_id: uuid::Uuid,
    ) -> anyhow::Result<std::collections::HashMap<uuid::Uuid, String>> {
        Ok(Repository::decision_knowledge_states(*self, project_id).await?)
    }
}
