//! Repository layer: the `Repository` trait (swappable storage) and the
//! SQLite implementation (solo mode, the only MVP distribution).

use std::str::FromStr;
use std::sync::Arc;

use async_trait::async_trait;
use kaizen_model::{
    Decision, DecisionOption, Experiment, ExperimentEvent, Goal, Link, Note, Project, Revision,
    Session, User,
};
use sqlx::Row;
use sqlx::SqlitePool;
use sqlx::sqlite::{SqliteConnectOptions, SqliteJournalMode, SqlitePoolOptions};
use uuid::Uuid;

use crate::auth::{SESSION_TTL_MS, sha256_hex};

#[derive(Debug, thiserror::Error)]
pub enum RepositoryError {
    #[error("{0}")]
    NotFound(String),
    #[error("unauthorized")]
    Unauthorized,
    #[error("forbidden")]
    Forbidden,
    #[error("{0}")]
    InvalidInput(String),
    #[error("{0}")]
    Conflict(String),
    #[error("rate limited")]
    RateLimited,
    #[error("io error")]
    Io(#[from] std::io::Error),
    #[error("invalid id")]
    Uuid(#[from] uuid::Error),
    #[error(transparent)]
    Database(#[from] sqlx::Error),
    #[error(transparent)]
    Migration(#[from] sqlx::migrate::MigrateError),
}

/// Swappable storage behind the routes. A Postgres implementation can later
/// replace the SQLite one without touching handlers.
#[async_trait]
pub trait Repository: Send + Sync {
    /// Whether the first user has been created (drives `/setup`).
    async fn is_setup_complete(&self) -> Result<bool, RepositoryError>;
    /// Persist the setup flag.
    async fn set_setup_complete(&self, complete: bool) -> Result<(), RepositoryError>;
    /// Create the first user and mark setup complete (idempotent: no-op if a
    /// user already exists).
    async fn create_first_user(
        &self,
        username: &str,
        display_name: &str,
        password_hash: &str,
    ) -> Result<User, RepositoryError>;
    async fn find_user_by_username(&self, username: &str) -> Result<Option<User>, RepositoryError>;
    async fn find_user_by_id(&self, id: Uuid) -> Result<Option<User>, RepositoryError>;
    /// Create a session for a user and return the raw token + CSRF token.
    async fn create_session(&self, user_id: Uuid) -> Result<Session, RepositoryError>;
    /// Resolve a raw session token to a live session (hash lookup).
    async fn session_by_token(&self, token: &str) -> Result<Option<Session>, RepositoryError>;
    /// Delete a session by its raw token (logout).
    async fn delete_session(&self, token: &str) -> Result<(), RepositoryError>;

    // -----------------------------------------------------------------------
    // Projects & goals
    // -----------------------------------------------------------------------

    async fn list_projects(&self) -> Result<Vec<Project>, RepositoryError>;
    async fn find_project(&self, id: Uuid) -> Result<Option<Project>, RepositoryError>;
    async fn create_project(
        &self,
        title: &str,
        summary: &str,
        status: &str,
    ) -> Result<Project, RepositoryError>;
    async fn update_project(
        &self,
        id: Uuid,
        title: &str,
        summary: &str,
        status: &str,
    ) -> Result<(), RepositoryError>;
    async fn delete_project(&self, id: Uuid) -> Result<(), RepositoryError>;

    async fn list_goals(&self, project_id: Uuid) -> Result<Vec<Goal>, RepositoryError>;
    async fn find_goal(&self, id: Uuid) -> Result<Option<Goal>, RepositoryError>;
    async fn create_goal(
        &self,
        project_id: Uuid,
        title: &str,
        body: &str,
    ) -> Result<Goal, RepositoryError>;
    async fn update_goal(
        &self,
        id: Uuid,
        title: &str,
        body: &str,
        status: &str,
    ) -> Result<(), RepositoryError>;
    async fn delete_goal(&self, id: Uuid) -> Result<(), RepositoryError>;

    /// Counts shown on the dashboard.
    async fn dashboard_counts(&self) -> Result<DashboardCounts, RepositoryError>;
    /// Counts shown on a project page.
    async fn project_counts(&self, project_id: Uuid) -> Result<ProjectCounts, RepositoryError>;

    // -----------------------------------------------------------------------
    // Decisions & revision history
    // -----------------------------------------------------------------------

    async fn list_decisions(&self, project_id: Uuid) -> Result<Vec<Decision>, RepositoryError>;
    async fn find_decision(&self, id: Uuid) -> Result<Option<Decision>, RepositoryError>;
    /// Create a decision (status `open`) and snapshot its first revision.
    async fn create_decision(
        &self,
        project_id: Uuid,
        goal_id: Option<Uuid>,
        title: &str,
        context: &str,
        options: &[DecisionOption],
    ) -> Result<Decision, RepositoryError>;
    /// Update the editable fields and append a revision.
    async fn update_decision(
        &self,
        id: Uuid,
        title: &str,
        context: &str,
        options: &[DecisionOption],
    ) -> Result<Decision, RepositoryError>;
    /// Resolve the decision (status `decided`/`rejected`), set rationale, and
    /// append a revision.
    async fn resolve_decision(
        &self,
        id: Uuid,
        status: &str,
        decided_option: Option<String>,
        rationale: &str,
        review_at_ms: Option<i64>,
    ) -> Result<Decision, RepositoryError>;
    async fn delete_decision(&self, id: Uuid) -> Result<(), RepositoryError>;
    /// Full history of an entity, oldest first.
    async fn list_revisions(
        &self,
        entity_type: &str,
        entity_id: Uuid,
    ) -> Result<Vec<Revision>, RepositoryError>;

    // -----------------------------------------------------------------------
    // Experiments & events (the timeline)
    // -----------------------------------------------------------------------

    async fn list_experiments(&self, project_id: Uuid) -> Result<Vec<Experiment>, RepositoryError>;
    async fn find_experiment(&self, id: Uuid) -> Result<Option<Experiment>, RepositoryError>;
    async fn create_experiment(
        &self,
        project_id: Uuid,
        goal_id: Option<Uuid>,
        decision_id: Option<Uuid>,
        title: &str,
        hypothesis: &str,
    ) -> Result<Experiment, RepositoryError>;
    /// Update editable fields plus status; `started_at`/`ended_at` are set the
    /// first time status moves to `running`/`done|abandoned`.
    async fn update_experiment(
        &self,
        id: Uuid,
        title: &str,
        hypothesis: &str,
        status: &str,
        result: &str,
        lesson: &str,
    ) -> Result<Experiment, RepositoryError>;
    async fn delete_experiment(&self, id: Uuid) -> Result<(), RepositoryError>;

    async fn list_events(
        &self,
        experiment_id: Uuid,
    ) -> Result<Vec<ExperimentEvent>, RepositoryError>;
    async fn create_event(
        &self,
        experiment_id: Uuid,
        kind: &str,
        at_ms: i64,
        note: &str,
    ) -> Result<ExperimentEvent, RepositoryError>;
    async fn delete_event(&self, id: Uuid) -> Result<(), RepositoryError>;

    /// Chronological story of a project: experiment start/end markers plus
    /// every recorded event, newest first.
    async fn timeline(&self, project_id: Uuid) -> Result<Vec<TimelineEntry>, RepositoryError>;

    // -----------------------------------------------------------------------
    // Knowledge: notes, links, graph
    // -----------------------------------------------------------------------

    async fn list_notes(&self, project_id: Uuid) -> Result<Vec<Note>, RepositoryError>;
    async fn find_note(&self, id: Uuid) -> Result<Option<Note>, RepositoryError>;
    /// Creates a note and records a `note` revision snapshot.
    async fn create_note(
        &self,
        project_id: Uuid,
        title: &str,
        body: &str,
        source_type: Option<&str>,
        source_id: Option<Uuid>,
    ) -> Result<Note, RepositoryError>;
    /// Updates a note and records a `note` revision snapshot.
    async fn update_note(&self, id: Uuid, title: &str, body: &str)
    -> Result<Note, RepositoryError>;
    async fn delete_note(&self, id: Uuid) -> Result<(), RepositoryError>;

    async fn list_links(&self, project_id: Uuid) -> Result<Vec<Link>, RepositoryError>;
    async fn create_link(
        &self,
        project_id: Uuid,
        from_type: &str,
        from_id: Uuid,
        to_type: &str,
        to_id: Uuid,
        kind: &str,
    ) -> Result<Link, RepositoryError>;
    async fn delete_link(&self, id: Uuid) -> Result<(), RepositoryError>;

    /// Nodes and edges of a project's knowledge graph. Nodes are the entities
    /// themselves; edges include both explicit links and the implicit
    /// references between them (goal/decision/experiment/note relationships).
    async fn graph(&self, project_id: Uuid) -> Result<GraphData, RepositoryError>;
}

/// One node of the project graph.
#[derive(Debug, Clone)]
pub struct GraphNode {
    /// `goal` | `decision` | `experiment` | `note`
    pub node_type: String,
    pub id: Uuid,
    pub title: String,
}

/// One edge of the project graph.
#[derive(Debug, Clone)]
pub struct GraphEdge {
    pub from_type: String,
    pub from_id: Uuid,
    pub to_type: String,
    pub to_id: Uuid,
    pub kind: String,
}

#[derive(Debug, Default)]
pub struct GraphData {
    pub nodes: Vec<GraphNode>,
    pub edges: Vec<GraphEdge>,
}

/// One row of a project's timeline.
#[derive(Debug, Clone)]
pub struct TimelineEntry {
    pub at_ms: i64,
    /// `experiment_started` | `experiment_ended` | one of the event kinds.
    pub kind: String,
    pub note: String,
    pub experiment_id: Uuid,
    pub experiment_title: String,
}

/// Aggregate counters for the dashboard.
#[derive(Debug, Clone, Copy, Default)]
pub struct DashboardCounts {
    pub projects: i64,
    pub open_goals: i64,
    pub done_goals: i64,
    pub decisions: i64,
    pub open_decisions: i64,
}

/// Aggregate counters for a single project.
#[derive(Debug, Clone, Copy, Default)]
pub struct ProjectCounts {
    pub open_goals: i64,
    pub total_goals: i64,
    pub decisions: i64,
    pub open_decisions: i64,
}

/// SQLite-backed repository (solo mode).
#[derive(Clone)]
pub struct SqliteRepository {
    pool: SqlitePool,
}

impl SqliteRepository {
    /// Connect to a SQLite database, creating the file if needed.
    pub async fn connect(database_url: &str) -> Result<Self, RepositoryError> {
        let options = SqliteConnectOptions::from_str(database_url)?
            .create_if_missing(true)
            .foreign_keys(true)
            .journal_mode(SqliteJournalMode::Wal);
        let pool = SqlitePoolOptions::new()
            .max_connections(5)
            .connect_with(options)
            .await?;
        Ok(Self { pool })
    }

    pub fn from_pool(pool: SqlitePool) -> Self {
        Self { pool }
    }

    /// Run pending migrations from the workspace `migrations/` directory.
    pub async fn migrate(&self) -> Result<(), RepositoryError> {
        sqlx::migrate!("../../migrations").run(&self.pool).await?;
        Ok(())
    }

    pub fn pool(&self) -> &SqlitePool {
        &self.pool
    }
}

#[async_trait]
impl Repository for SqliteRepository {
    async fn is_setup_complete(&self) -> Result<bool, RepositoryError> {
        let row = sqlx::query("SELECT value FROM settings WHERE key = 'setup.complete'")
            .fetch_optional(&self.pool)
            .await?;
        Ok(match row {
            Some(r) => r.get::<String, _>("value") == "1",
            None => false,
        })
    }

    async fn set_setup_complete(&self, complete: bool) -> Result<(), RepositoryError> {
        sqlx::query(
            "INSERT INTO settings (key, value, updated_at) VALUES ('setup.complete', ?, ?)
             ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at",
        )
        .bind(if complete { "1" } else { "0" })
        .bind(kaizen_content::now_ms())
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn create_first_user(
        &self,
        username: &str,
        display_name: &str,
        password_hash: &str,
    ) -> Result<User, RepositoryError> {
        let mut tx = self.pool.begin().await?;
        let existing: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM users")
            .fetch_one(&mut *tx)
            .await?;
        if existing > 0 {
            return Err(RepositoryError::Conflict("setup already complete".into()));
        }
        let id = Uuid::new_v4();
        sqlx::query(
            "INSERT INTO users (id, username, display_name, password_hash, created_at_ms)
             VALUES (?, ?, ?, ?, ?)",
        )
        .bind(id.to_string())
        .bind(username)
        .bind(display_name)
        .bind(password_hash)
        .bind(kaizen_content::now_ms())
        .execute(&mut *tx)
        .await?;
        sqlx::query(
            "INSERT INTO settings (key, value, updated_at) VALUES ('setup.complete', '1', ?)
             ON CONFLICT(key) DO UPDATE SET value = '1', updated_at = excluded.updated_at",
        )
        .bind(kaizen_content::now_ms())
        .execute(&mut *tx)
        .await?;
        tx.commit().await?;
        Ok(User {
            id,
            username: username.to_string(),
            display_name: display_name.to_string(),
            created_at_ms: kaizen_content::now_ms(),
            password_hash: password_hash.to_string(),
        })
    }

    async fn find_user_by_username(&self, username: &str) -> Result<Option<User>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, username, display_name, password_hash, created_at_ms
             FROM users WHERE username = ?",
        )
        .bind(username)
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_user(&r)))
    }

    async fn find_user_by_id(&self, id: Uuid) -> Result<Option<User>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, username, display_name, password_hash, created_at_ms
             FROM users WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_user(&r)))
    }

    async fn create_session(&self, user_id: Uuid) -> Result<Session, RepositoryError> {
        let token = Uuid::new_v4().to_string();
        let csrf = Uuid::new_v4().to_string();
        let token_hash = sha256_hex(&token);
        let expires_at_ms = kaizen_content::now_ms() + SESSION_TTL_MS;
        sqlx::query(
            "INSERT INTO sessions (token_hash, user_id, csrf, expires_at_ms)
             VALUES (?, ?, ?, ?)",
        )
        .bind(token_hash)
        .bind(user_id.to_string())
        .bind(&csrf)
        .bind(expires_at_ms)
        .execute(&self.pool)
        .await?;
        Ok(Session {
            token,
            csrf,
            user_id,
            expires_at_ms,
        })
    }

    async fn session_by_token(&self, token: &str) -> Result<Option<Session>, RepositoryError> {
        let token_hash = sha256_hex(token);
        let row = sqlx::query(
            "SELECT token_hash, user_id, csrf, expires_at_ms
             FROM sessions WHERE token_hash = ? AND expires_at_ms > ?",
        )
        .bind(token_hash)
        .bind(kaizen_content::now_ms())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| Session {
            token: token.to_string(),
            user_id: Uuid::from_str(&r.get::<String, _>("user_id")).unwrap_or_default(),
            csrf: r.get("csrf"),
            expires_at_ms: r.get("expires_at_ms"),
        }))
    }

    async fn delete_session(&self, token: &str) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM sessions WHERE token_hash = ?")
            .bind(sha256_hex(token))
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Projects & goals
    // -----------------------------------------------------------------------

    async fn list_projects(&self) -> Result<Vec<Project>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, title, summary, status, created_at_ms, updated_at_ms
             FROM projects ORDER BY updated_at_ms DESC",
        )
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_project).collect())
    }

    async fn find_project(&self, id: Uuid) -> Result<Option<Project>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, title, summary, status, created_at_ms, updated_at_ms
             FROM projects WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_project(&r)))
    }

    async fn create_project(
        &self,
        title: &str,
        summary: &str,
        status: &str,
    ) -> Result<Project, RepositoryError> {
        let id = Uuid::new_v4();
        let now = kaizen_content::now_ms();
        sqlx::query(
            "INSERT INTO projects (id, title, summary, status, created_at_ms, updated_at_ms)
             VALUES (?, ?, ?, ?, ?, ?)",
        )
        .bind(id.to_string())
        .bind(title)
        .bind(summary)
        .bind(status)
        .bind(now)
        .bind(now)
        .execute(&self.pool)
        .await?;
        Ok(Project {
            id,
            title: title.to_string(),
            summary: summary.to_string(),
            status: status.to_string(),
            created_at_ms: now,
            updated_at_ms: now,
        })
    }

    async fn update_project(
        &self,
        id: Uuid,
        title: &str,
        summary: &str,
        status: &str,
    ) -> Result<(), RepositoryError> {
        sqlx::query(
            "UPDATE projects SET title = ?, summary = ?, status = ?, updated_at_ms = ?
             WHERE id = ?",
        )
        .bind(title)
        .bind(summary)
        .bind(status)
        .bind(kaizen_content::now_ms())
        .bind(id.to_string())
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn delete_project(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM projects WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn list_goals(&self, project_id: Uuid) -> Result<Vec<Goal>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, project_id, title, body, status, created_at_ms, updated_at_ms
             FROM goals WHERE project_id = ? ORDER BY updated_at_ms DESC",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_goal).collect())
    }

    async fn find_goal(&self, id: Uuid) -> Result<Option<Goal>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, project_id, title, body, status, created_at_ms, updated_at_ms
             FROM goals WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_goal(&r)))
    }

    async fn create_goal(
        &self,
        project_id: Uuid,
        title: &str,
        body: &str,
    ) -> Result<Goal, RepositoryError> {
        let id = Uuid::new_v4();
        let now = kaizen_content::now_ms();
        sqlx::query(
            "INSERT INTO goals (id, project_id, title, body, status, created_at_ms, updated_at_ms)
             VALUES (?, ?, ?, ?, 'open', ?, ?)",
        )
        .bind(id.to_string())
        .bind(project_id.to_string())
        .bind(title)
        .bind(body)
        .bind(now)
        .bind(now)
        .execute(&self.pool)
        .await?;
        Ok(Goal {
            id,
            project_id,
            title: title.to_string(),
            body: body.to_string(),
            status: "open".into(),
            created_at_ms: now,
            updated_at_ms: now,
        })
    }

    async fn update_goal(
        &self,
        id: Uuid,
        title: &str,
        body: &str,
        status: &str,
    ) -> Result<(), RepositoryError> {
        sqlx::query(
            "UPDATE goals SET title = ?, body = ?, status = ?, updated_at_ms = ?
             WHERE id = ?",
        )
        .bind(title)
        .bind(body)
        .bind(status)
        .bind(kaizen_content::now_ms())
        .bind(id.to_string())
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn delete_goal(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM goals WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn dashboard_counts(&self) -> Result<DashboardCounts, RepositoryError> {
        let projects: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM projects")
            .fetch_one(&self.pool)
            .await?;
        let open_goals: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM goals WHERE status = 'open'")
                .fetch_one(&self.pool)
                .await?;
        let done_goals: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM goals WHERE status = 'done'")
                .fetch_one(&self.pool)
                .await?;
        let decisions: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM decisions")
            .fetch_one(&self.pool)
            .await?;
        let open_decisions: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM decisions WHERE status = 'open'")
                .fetch_one(&self.pool)
                .await?;
        Ok(DashboardCounts {
            projects,
            open_goals,
            done_goals,
            decisions,
            open_decisions,
        })
    }

    async fn project_counts(&self, project_id: Uuid) -> Result<ProjectCounts, RepositoryError> {
        let open_goals: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM goals WHERE project_id = ? AND status = 'open'",
        )
        .bind(project_id.to_string())
        .fetch_one(&self.pool)
        .await?;
        let total_goals: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM goals WHERE project_id = ?")
                .bind(project_id.to_string())
                .fetch_one(&self.pool)
                .await?;
        let decisions: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM decisions WHERE project_id = ?")
                .bind(project_id.to_string())
                .fetch_one(&self.pool)
                .await?;
        let open_decisions: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM decisions WHERE project_id = ? AND status = 'open'",
        )
        .bind(project_id.to_string())
        .fetch_one(&self.pool)
        .await?;
        Ok(ProjectCounts {
            open_goals,
            total_goals,
            decisions,
            open_decisions,
        })
    }

    // -----------------------------------------------------------------------
    // Decisions & revision history
    // -----------------------------------------------------------------------

    async fn list_decisions(&self, project_id: Uuid) -> Result<Vec<Decision>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, project_id, goal_id, title, context, options, status,
                    decided_option, rationale, decided_at_ms, review_at_ms,
                    created_at_ms, updated_at_ms
             FROM decisions WHERE project_id = ? ORDER BY updated_at_ms DESC",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_decision).collect())
    }

    async fn find_decision(&self, id: Uuid) -> Result<Option<Decision>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, project_id, goal_id, title, context, options, status,
                    decided_option, rationale, decided_at_ms, review_at_ms,
                    created_at_ms, updated_at_ms
             FROM decisions WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_decision(&r)))
    }

    async fn create_decision(
        &self,
        project_id: Uuid,
        goal_id: Option<Uuid>,
        title: &str,
        context: &str,
        options: &[DecisionOption],
    ) -> Result<Decision, RepositoryError> {
        let decision = Decision {
            id: Uuid::new_v4(),
            project_id,
            goal_id,
            title: title.to_string(),
            context: context.to_string(),
            options: options.to_vec(),
            status: "open".into(),
            decided_option: None,
            rationale: String::new(),
            decided_at_ms: None,
            review_at_ms: None,
            created_at_ms: kaizen_content::now_ms(),
            updated_at_ms: kaizen_content::now_ms(),
        };
        let mut tx = self.pool.begin().await?;
        sqlx::query(
            "INSERT INTO decisions (id, project_id, goal_id, title, context, options, status,
                    decided_option, rationale, decided_at_ms, review_at_ms, created_at_ms, updated_at_ms)
             VALUES (?, ?, ?, ?, ?, ?, 'open', NULL, '', NULL, NULL, ?, ?)",
        )
        .bind(decision.id.to_string())
        .bind(decision.project_id.to_string())
        .bind(decision.goal_id.map(|g| g.to_string()))
        .bind(&decision.title)
        .bind(&decision.context)
        .bind(serde_json::to_string(&decision.options).unwrap_or_else(|_| "[]".into()))
        .bind(decision.created_at_ms)
        .bind(decision.updated_at_ms)
        .execute(&mut *tx)
        .await?;
        insert_revision(
            &mut tx,
            "decision",
            decision.id,
            &decision_snapshot_md(&decision),
        )
        .await?;
        tx.commit().await?;
        Ok(decision)
    }

    async fn update_decision(
        &self,
        id: Uuid,
        title: &str,
        context: &str,
        options: &[DecisionOption],
    ) -> Result<Decision, RepositoryError> {
        let mut tx = self.pool.begin().await?;
        let now = kaizen_content::now_ms();
        sqlx::query(
            "UPDATE decisions SET title = ?, context = ?, options = ?, updated_at_ms = ?
             WHERE id = ?",
        )
        .bind(title)
        .bind(context)
        .bind(serde_json::to_string(options).unwrap_or_else(|_| "[]".into()))
        .bind(now)
        .bind(id.to_string())
        .execute(&mut *tx)
        .await?;
        let decision = fetch_decision(&mut tx, id).await?;
        insert_revision(&mut tx, "decision", id, &decision_snapshot_md(&decision)).await?;
        tx.commit().await?;
        Ok(decision)
    }

    async fn resolve_decision(
        &self,
        id: Uuid,
        status: &str,
        decided_option: Option<String>,
        rationale: &str,
        review_at_ms: Option<i64>,
    ) -> Result<Decision, RepositoryError> {
        let mut tx = self.pool.begin().await?;
        let now = kaizen_content::now_ms();
        let decided_at_ms = if status == "open" { None } else { Some(now) };
        sqlx::query(
            "UPDATE decisions SET status = ?, decided_option = ?, rationale = ?,
                    decided_at_ms = ?, review_at_ms = ?, updated_at_ms = ?
             WHERE id = ?",
        )
        .bind(status)
        .bind(decided_option)
        .bind(rationale)
        .bind(decided_at_ms)
        .bind(review_at_ms)
        .bind(now)
        .bind(id.to_string())
        .execute(&mut *tx)
        .await?;
        let decision = fetch_decision(&mut tx, id).await?;
        insert_revision(&mut tx, "decision", id, &decision_snapshot_md(&decision)).await?;
        tx.commit().await?;
        Ok(decision)
    }

    async fn delete_decision(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM decisions WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn list_revisions(
        &self,
        entity_type: &str,
        entity_id: Uuid,
    ) -> Result<Vec<Revision>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, entity_type, entity_id, snapshot, created_at_ms
             FROM revisions WHERE entity_type = ? AND entity_id = ?
             ORDER BY created_at_ms ASC",
        )
        .bind(entity_type)
        .bind(entity_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows
            .iter()
            .map(|r| Revision {
                id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
                entity_type: r.get("entity_type"),
                entity_id: Uuid::from_str(&r.get::<String, _>("entity_id")).unwrap_or_default(),
                snapshot: r.get("snapshot"),
                created_at_ms: r.get("created_at_ms"),
            })
            .collect())
    }

    // -----------------------------------------------------------------------
    // Experiments & events (the timeline)
    // -----------------------------------------------------------------------

    async fn list_experiments(&self, project_id: Uuid) -> Result<Vec<Experiment>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, project_id, goal_id, decision_id, title, hypothesis, status,
                    started_at_ms, ended_at_ms, result, lesson, created_at_ms, updated_at_ms
             FROM experiments WHERE project_id = ? ORDER BY updated_at_ms DESC",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_experiment).collect())
    }

    async fn find_experiment(&self, id: Uuid) -> Result<Option<Experiment>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, project_id, goal_id, decision_id, title, hypothesis, status,
                    started_at_ms, ended_at_ms, result, lesson, created_at_ms, updated_at_ms
             FROM experiments WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_experiment(&r)))
    }

    async fn create_experiment(
        &self,
        project_id: Uuid,
        goal_id: Option<Uuid>,
        decision_id: Option<Uuid>,
        title: &str,
        hypothesis: &str,
    ) -> Result<Experiment, RepositoryError> {
        let id = Uuid::new_v4();
        let now = kaizen_content::now_ms();
        sqlx::query(
            "INSERT INTO experiments (id, project_id, goal_id, decision_id, title, hypothesis,
                    status, started_at_ms, ended_at_ms, result, lesson, created_at_ms, updated_at_ms)
             VALUES (?, ?, ?, ?, ?, ?, 'planned', NULL, NULL, '', '', ?, ?)",
        )
        .bind(id.to_string())
        .bind(project_id.to_string())
        .bind(goal_id.map(|g| g.to_string()))
        .bind(decision_id.map(|d| d.to_string()))
        .bind(title)
        .bind(hypothesis)
        .bind(now)
        .bind(now)
        .execute(&self.pool)
        .await?;
        Ok(Experiment {
            id,
            project_id,
            goal_id,
            decision_id,
            title: title.to_string(),
            hypothesis: hypothesis.to_string(),
            status: "planned".into(),
            started_at_ms: None,
            ended_at_ms: None,
            result: String::new(),
            lesson: String::new(),
            created_at_ms: now,
            updated_at_ms: now,
        })
    }

    async fn update_experiment(
        &self,
        id: Uuid,
        title: &str,
        hypothesis: &str,
        status: &str,
        result: &str,
        lesson: &str,
    ) -> Result<Experiment, RepositoryError> {
        let existing = self
            .find_experiment(id)
            .await?
            .ok_or_else(|| RepositoryError::NotFound("experiment".into()))?;
        let now = kaizen_content::now_ms();
        let mut started = existing.started_at_ms;
        let mut ended = existing.ended_at_ms;
        match status {
            "running" => {
                if started.is_none() {
                    started = Some(now);
                }
                ended = None;
            }
            "done" | "abandoned" => {
                if ended.is_none() {
                    ended = Some(now);
                }
            }
            _ => {}
        }
        sqlx::query(
            "UPDATE experiments SET title = ?, hypothesis = ?, status = ?,
                    started_at_ms = ?, ended_at_ms = ?, result = ?, lesson = ?,
                    updated_at_ms = ?
             WHERE id = ?",
        )
        .bind(title)
        .bind(hypothesis)
        .bind(status)
        .bind(started)
        .bind(ended)
        .bind(result)
        .bind(lesson)
        .bind(now)
        .bind(id.to_string())
        .execute(&self.pool)
        .await?;
        self.find_experiment(id)
            .await?
            .ok_or_else(|| RepositoryError::NotFound("experiment".into()))
    }

    async fn delete_experiment(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM experiments WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn list_events(
        &self,
        experiment_id: Uuid,
    ) -> Result<Vec<ExperimentEvent>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, experiment_id, kind, at_ms, note, created_at_ms
             FROM events WHERE experiment_id = ? ORDER BY at_ms ASC",
        )
        .bind(experiment_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows
            .iter()
            .map(|r| ExperimentEvent {
                id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
                experiment_id: Uuid::from_str(&r.get::<String, _>("experiment_id"))
                    .unwrap_or_default(),
                kind: r.get("kind"),
                at_ms: r.get("at_ms"),
                note: r.get("note"),
                created_at_ms: r.get("created_at_ms"),
            })
            .collect())
    }

    async fn create_event(
        &self,
        experiment_id: Uuid,
        kind: &str,
        at_ms: i64,
        note: &str,
    ) -> Result<ExperimentEvent, RepositoryError> {
        let id = Uuid::new_v4();
        sqlx::query(
            "INSERT INTO events (id, experiment_id, kind, at_ms, note, created_at_ms)
             VALUES (?, ?, ?, ?, ?, ?)",
        )
        .bind(id.to_string())
        .bind(experiment_id.to_string())
        .bind(kind)
        .bind(at_ms)
        .bind(note)
        .bind(kaizen_content::now_ms())
        .execute(&self.pool)
        .await?;
        Ok(ExperimentEvent {
            id,
            experiment_id,
            kind: kind.to_string(),
            at_ms,
            note: note.to_string(),
            created_at_ms: kaizen_content::now_ms(),
        })
    }

    async fn delete_event(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM events WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn timeline(&self, project_id: Uuid) -> Result<Vec<TimelineEntry>, RepositoryError> {
        let mut entries = Vec::new();
        for e in self.list_experiments(project_id).await? {
            if let Some(started) = e.started_at_ms {
                entries.push(TimelineEntry {
                    at_ms: started,
                    kind: "experiment_started".into(),
                    note: format!("Started “{}”", e.title),
                    experiment_id: e.id,
                    experiment_title: e.title.clone(),
                });
            }
            if let Some(ended) = e.ended_at_ms {
                entries.push(TimelineEntry {
                    at_ms: ended,
                    kind: "experiment_ended".into(),
                    note: if e.status == "done" {
                        format!("Completed “{}”", e.title)
                    } else {
                        format!("Abandoned “{}”", e.title)
                    },
                    experiment_id: e.id,
                    experiment_title: e.title.clone(),
                });
            }
        }
        let rows = sqlx::query(
            "SELECT e.at_ms, e.kind, e.note, e.experiment_id, x.title AS experiment_title
             FROM events e JOIN experiments x ON x.id = e.experiment_id
             WHERE x.project_id = ?",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        for r in &rows {
            entries.push(TimelineEntry {
                at_ms: r.get("at_ms"),
                kind: r.get("kind"),
                note: r.get("note"),
                experiment_id: Uuid::from_str(&r.get::<String, _>("experiment_id"))
                    .unwrap_or_default(),
                experiment_title: r.get("experiment_title"),
            });
        }
        entries.sort_by(|a, b| b.at_ms.cmp(&a.at_ms));
        Ok(entries)
    }

    // -----------------------------------------------------------------------
    // Knowledge: notes, links, graph
    // -----------------------------------------------------------------------

    async fn list_notes(&self, project_id: Uuid) -> Result<Vec<Note>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, project_id, title, body, source_type, source_id, created_at_ms, updated_at_ms
             FROM notes WHERE project_id = ? ORDER BY updated_at_ms DESC",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_note).collect())
    }

    async fn find_note(&self, id: Uuid) -> Result<Option<Note>, RepositoryError> {
        let row = sqlx::query(
            "SELECT id, project_id, title, body, source_type, source_id, created_at_ms, updated_at_ms
             FROM notes WHERE id = ?",
        )
        .bind(id.to_string())
        .fetch_optional(&self.pool)
        .await?;
        Ok(row.map(|r| row_to_note(&r)))
    }

    async fn create_note(
        &self,
        project_id: Uuid,
        title: &str,
        body: &str,
        source_type: Option<&str>,
        source_id: Option<Uuid>,
    ) -> Result<Note, RepositoryError> {
        let mut tx = self.pool.begin().await?;
        let id = Uuid::new_v4();
        let now = kaizen_content::now_ms();
        sqlx::query(
            "INSERT INTO notes (id, project_id, title, body, source_type, source_id, created_at_ms, updated_at_ms)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        )
        .bind(id.to_string())
        .bind(project_id.to_string())
        .bind(title)
        .bind(body)
        .bind(source_type)
        .bind(source_id.map(|s| s.to_string()))
        .bind(now)
        .bind(now)
        .execute(&mut *tx)
        .await?;
        let note = fetch_note(&mut tx, id).await?;
        insert_revision(&mut tx, "note", id, &note_snapshot_md(&note)).await?;
        tx.commit().await?;
        Ok(note)
    }

    async fn update_note(
        &self,
        id: Uuid,
        title: &str,
        body: &str,
    ) -> Result<Note, RepositoryError> {
        let mut tx = self.pool.begin().await?;
        sqlx::query("UPDATE notes SET title = ?, body = ?, updated_at_ms = ? WHERE id = ?")
            .bind(title)
            .bind(body)
            .bind(kaizen_content::now_ms())
            .bind(id.to_string())
            .execute(&mut *tx)
            .await?;
        let note = fetch_note(&mut tx, id).await?;
        insert_revision(&mut tx, "note", id, &note_snapshot_md(&note)).await?;
        tx.commit().await?;
        Ok(note)
    }

    async fn delete_note(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM notes WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn list_links(&self, project_id: Uuid) -> Result<Vec<Link>, RepositoryError> {
        let rows = sqlx::query(
            "SELECT id, project_id, from_type, from_id, to_type, to_id, kind, created_at_ms
             FROM links WHERE project_id = ? ORDER BY created_at_ms DESC",
        )
        .bind(project_id.to_string())
        .fetch_all(&self.pool)
        .await?;
        Ok(rows.iter().map(row_to_link).collect())
    }

    async fn create_link(
        &self,
        project_id: Uuid,
        from_type: &str,
        from_id: Uuid,
        to_type: &str,
        to_id: Uuid,
        kind: &str,
    ) -> Result<Link, RepositoryError> {
        if from_id == to_id && from_type == to_type {
            return Err(RepositoryError::InvalidInput(
                "cannot link an entity to itself".into(),
            ));
        }
        let id = Uuid::new_v4();
        sqlx::query(
            "INSERT INTO links (id, project_id, from_type, from_id, to_type, to_id, kind, created_at_ms)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        )
        .bind(id.to_string())
        .bind(project_id.to_string())
        .bind(from_type)
        .bind(from_id.to_string())
        .bind(to_type)
        .bind(to_id.to_string())
        .bind(kind)
        .bind(kaizen_content::now_ms())
        .execute(&self.pool)
        .await?;
        Ok(Link {
            id,
            project_id,
            from_type: from_type.to_string(),
            from_id,
            to_type: to_type.to_string(),
            to_id,
            kind: kind.to_string(),
            created_at_ms: kaizen_content::now_ms(),
        })
    }

    async fn delete_link(&self, id: Uuid) -> Result<(), RepositoryError> {
        sqlx::query("DELETE FROM links WHERE id = ?")
            .bind(id.to_string())
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn graph(&self, project_id: Uuid) -> Result<GraphData, RepositoryError> {
        let mut data = GraphData::default();
        for g in self.list_goals(project_id).await? {
            data.nodes.push(GraphNode {
                node_type: "goal".into(),
                id: g.id,
                title: g.title,
            });
        }
        for d in self.list_decisions(project_id).await? {
            data.nodes.push(GraphNode {
                node_type: "decision".into(),
                id: d.id,
                title: d.title.clone(),
            });
            if let Some(goal_id) = d.goal_id {
                data.edges.push(GraphEdge {
                    from_type: "decision".into(),
                    from_id: d.id,
                    to_type: "goal".into(),
                    to_id: goal_id,
                    kind: "serves".into(),
                });
            }
        }
        for e in self.list_experiments(project_id).await? {
            data.nodes.push(GraphNode {
                node_type: "experiment".into(),
                id: e.id,
                title: e.title.clone(),
            });
            if let Some(goal_id) = e.goal_id {
                data.edges.push(GraphEdge {
                    from_type: "experiment".into(),
                    from_id: e.id,
                    to_type: "goal".into(),
                    to_id: goal_id,
                    kind: "serves".into(),
                });
            }
            if let Some(decision_id) = e.decision_id {
                data.edges.push(GraphEdge {
                    from_type: "experiment".into(),
                    from_id: e.id,
                    to_type: "decision".into(),
                    to_id: decision_id,
                    kind: "tests".into(),
                });
            }
        }
        for n in self.list_notes(project_id).await? {
            data.nodes.push(GraphNode {
                node_type: "note".into(),
                id: n.id,
                title: n.title.clone(),
            });
            if let (Some(source_type), Some(source_id)) = (n.source_type, n.source_id) {
                data.edges.push(GraphEdge {
                    from_type: "note".into(),
                    from_id: n.id,
                    to_type: source_type,
                    to_id: source_id,
                    kind: "from".into(),
                });
            }
        }
        for l in self.list_links(project_id).await? {
            data.edges.push(GraphEdge {
                from_type: l.from_type,
                from_id: l.from_id,
                to_type: l.to_type,
                to_id: l.to_id,
                kind: l.kind,
            });
        }
        Ok(data)
    }
}

/// Load a decision inside an existing transaction.
async fn fetch_decision(
    tx: &mut sqlx::Transaction<'_, sqlx::Sqlite>,
    id: Uuid,
) -> Result<Decision, RepositoryError> {
    let row = sqlx::query(
        "SELECT id, project_id, goal_id, title, context, options, status,
                decided_option, rationale, decided_at_ms, review_at_ms,
                created_at_ms, updated_at_ms
         FROM decisions WHERE id = ?",
    )
    .bind(id.to_string())
    .fetch_optional(&mut **tx)
    .await?;
    row.map(|r| row_to_decision(&r))
        .ok_or_else(|| RepositoryError::NotFound("decision".into()))
}

/// Append an immutable snapshot revision inside the caller's transaction.
async fn insert_revision(
    tx: &mut sqlx::Transaction<'_, sqlx::Sqlite>,
    entity_type: &str,
    entity_id: Uuid,
    snapshot: &str,
) -> Result<(), RepositoryError> {
    sqlx::query(
        "INSERT INTO revisions (id, entity_type, entity_id, snapshot, created_at_ms)
         VALUES (?, ?, ?, ?, ?)",
    )
    .bind(Uuid::new_v4().to_string())
    .bind(entity_type)
    .bind(entity_id.to_string())
    .bind(snapshot)
    .bind(kaizen_content::now_ms())
    .execute(&mut **tx)
    .await?;
    Ok(())
}

/// Markdown snapshot of a decision's full state, stored as a revision.
fn decision_snapshot_md(d: &Decision) -> String {
    let mut s = format!(
        "# {}\n\nStatus: **{}**\n\n## Context\n{}\n",
        d.title, d.status, d.context
    );
    s.push_str("\n## Options\n");
    for o in &d.options {
        s.push_str(&format!(
            "\n### {}\n\n**Pros**\n\n{}\n\n**Cons**\n\n{}\n",
            o.label, o.pros, o.cons
        ));
    }
    if let Some(option_id) = &d.decided_option {
        let label = d
            .options
            .iter()
            .find(|o| &o.id == option_id)
            .map(|o| o.label.as_str())
            .unwrap_or(option_id);
        s.push_str(&format!(
            "\n## Decision\n\nChose: **{label}**\n\n{rationale}\n",
            rationale = d.rationale
        ));
    }
    if let Some(review_at) = d.review_at_ms {
        s.push_str(&format!(
            "\nReview on: {}\n",
            kaizen_content::format_date_ms(review_at)
        ));
    }
    s
}

/// Fetch a note inside the caller's transaction.
async fn fetch_note(
    tx: &mut sqlx::Transaction<'_, sqlx::Sqlite>,
    id: Uuid,
) -> Result<Note, RepositoryError> {
    let row = sqlx::query(
        "SELECT id, project_id, title, body, source_type, source_id, created_at_ms, updated_at_ms
         FROM notes WHERE id = ?",
    )
    .bind(id.to_string())
    .fetch_optional(&mut **tx)
    .await?;
    row.map(|r| row_to_note(&r))
        .ok_or_else(|| RepositoryError::NotFound("note".into()))
}

/// Markdown snapshot of a note, stored as a revision.
fn note_snapshot_md(n: &Note) -> String {
    format!("# {}\n\n{}", n.title, n.body)
}

fn row_to_user(r: &sqlx::sqlite::SqliteRow) -> User {
    User {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        username: r.get("username"),
        display_name: r.get("display_name"),
        password_hash: r.get("password_hash"),
        created_at_ms: r.get("created_at_ms"),
    }
}

fn row_to_project(r: &sqlx::sqlite::SqliteRow) -> Project {
    Project {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        title: r.get("title"),
        summary: r.get("summary"),
        status: r.get("status"),
        created_at_ms: r.get("created_at_ms"),
        updated_at_ms: r.get("updated_at_ms"),
    }
}

fn row_to_goal(r: &sqlx::sqlite::SqliteRow) -> Goal {
    Goal {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        project_id: Uuid::from_str(&r.get::<String, _>("project_id")).unwrap_or_default(),
        title: r.get("title"),
        body: r.get("body"),
        status: r.get("status"),
        created_at_ms: r.get("created_at_ms"),
        updated_at_ms: r.get("updated_at_ms"),
    }
}

fn row_to_decision(r: &sqlx::sqlite::SqliteRow) -> Decision {
    let options: Vec<DecisionOption> =
        serde_json::from_str(&r.get::<String, _>("options")).unwrap_or_default();
    Decision {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        project_id: Uuid::from_str(&r.get::<String, _>("project_id")).unwrap_or_default(),
        goal_id: r
            .get::<Option<String>, _>("goal_id")
            .and_then(|s| Uuid::from_str(&s).ok()),
        title: r.get("title"),
        context: r.get("context"),
        options,
        status: r.get("status"),
        decided_option: r.get("decided_option"),
        rationale: r.get("rationale"),
        decided_at_ms: r.get("decided_at_ms"),
        review_at_ms: r.get("review_at_ms"),
        created_at_ms: r.get("created_at_ms"),
        updated_at_ms: r.get("updated_at_ms"),
    }
}

fn row_to_experiment(r: &sqlx::sqlite::SqliteRow) -> Experiment {
    Experiment {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        project_id: Uuid::from_str(&r.get::<String, _>("project_id")).unwrap_or_default(),
        goal_id: r
            .get::<Option<String>, _>("goal_id")
            .and_then(|s| Uuid::from_str(&s).ok()),
        decision_id: r
            .get::<Option<String>, _>("decision_id")
            .and_then(|s| Uuid::from_str(&s).ok()),
        title: r.get("title"),
        hypothesis: r.get("hypothesis"),
        status: r.get("status"),
        started_at_ms: r.get("started_at_ms"),
        ended_at_ms: r.get("ended_at_ms"),
        result: r.get("result"),
        lesson: r.get("lesson"),
        created_at_ms: r.get("created_at_ms"),
        updated_at_ms: r.get("updated_at_ms"),
    }
}

fn row_to_note(r: &sqlx::sqlite::SqliteRow) -> Note {
    Note {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        project_id: Uuid::from_str(&r.get::<String, _>("project_id")).unwrap_or_default(),
        title: r.get("title"),
        body: r.get("body"),
        source_type: r.get("source_type"),
        source_id: r
            .get::<Option<String>, _>("source_id")
            .and_then(|s| Uuid::from_str(&s).ok()),
        created_at_ms: r.get("created_at_ms"),
        updated_at_ms: r.get("updated_at_ms"),
    }
}

fn row_to_link(r: &sqlx::sqlite::SqliteRow) -> Link {
    Link {
        id: Uuid::from_str(&r.get::<String, _>("id")).unwrap_or_default(),
        project_id: Uuid::from_str(&r.get::<String, _>("project_id")).unwrap_or_default(),
        from_type: r.get("from_type"),
        from_id: Uuid::from_str(&r.get::<String, _>("from_id")).unwrap_or_default(),
        to_type: r.get("to_type"),
        to_id: Uuid::from_str(&r.get::<String, _>("to_id")).unwrap_or_default(),
        kind: r.get("kind"),
        created_at_ms: r.get("created_at_ms"),
    }
}

/// Convenience wrapper so handlers can hold `Arc<dyn Repository>` without
/// carrying the concrete type.
pub fn repo_box(repo: SqliteRepository) -> Arc<dyn Repository> {
    Arc::new(repo)
}
