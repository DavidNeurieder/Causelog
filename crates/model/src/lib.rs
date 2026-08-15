//! Kaizen core types. Schema lives in `../migrations`; row→struct mappers
//! live in the server crate's repository layer (mirroring Forgepost).

use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub username: String,
    pub display_name: String,
    pub created_at_ms: i64,
    /// Argon2 hash. Never serialized or exposed through the API.
    #[serde(skip)]
    pub password_hash: String,
}

#[derive(Debug, Clone)]
pub struct Session {
    /// Raw bearer token stored in the cookie; only its SHA-256 is persisted.
    pub token: String,
    pub csrf: String,
    pub user_id: Uuid,
    pub expires_at_ms: i64,
}

#[derive(Debug, Clone)]
pub struct Project {
    pub id: Uuid,
    pub title: String,
    pub summary: String,
    /// `active` | `paused` | `archived`
    pub status: String,
    pub created_at_ms: i64,
    pub updated_at_ms: i64,
}

#[derive(Debug, Clone)]
pub struct Goal {
    pub id: Uuid,
    pub project_id: Uuid,
    pub title: String,
    pub body: String,
    /// `open` | `done` | `dropped`
    pub status: String,
    pub created_at_ms: i64,
    pub updated_at_ms: i64,
}
