//! Repository layer: the `Repository` trait (swappable storage) and the
//! SQLite implementation (solo mode, the only MVP distribution).

use std::str::FromStr;
use std::sync::Arc;

use async_trait::async_trait;
use sqlx::Row;
use sqlx::SqlitePool;
use sqlx::sqlite::{SqliteConnectOptions, SqliteJournalMode, SqlitePoolOptions};

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
}

/// Convenience wrapper so handlers can hold `Arc<dyn Repository>` without
/// carrying the concrete type.
pub fn repo_box(repo: SqliteRepository) -> Arc<dyn Repository> {
    Arc::new(repo)
}
