//! Repository layer: the `Repository` trait (swappable storage) and the
//! SQLite implementation (solo mode, the only MVP distribution).

use std::str::FromStr;
use std::sync::Arc;

use async_trait::async_trait;
use kaizen_model::{Goal, Project, Session, User};
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

/// Convenience wrapper so handlers can hold `Arc<dyn Repository>` without
/// carrying the concrete type.
pub fn repo_box(repo: SqliteRepository) -> Arc<dyn Repository> {
    Arc::new(repo)
}
