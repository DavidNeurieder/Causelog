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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecisionOption {
    pub id: String,
    pub label: String,
    /// Markdown; rendered as the "pros" column.
    pub pros: String,
    /// Markdown; rendered as the "cons" column.
    pub cons: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decision {
    pub id: Uuid,
    pub project_id: Uuid,
    pub goal_id: Option<Uuid>,
    pub title: String,
    /// Markdown; the situation that forced the choice.
    pub context: String,
    pub options: Vec<DecisionOption>,
    /// `open` | `decided` | `rejected`
    pub status: String,
    /// Id of the chosen option (`decided` only).
    pub decided_option: Option<String>,
    /// Markdown; the reasoning behind the resolution.
    pub rationale: String,
    pub decided_at_ms: Option<i64>,
    /// Optional review date: the decision is revisited on or after this day.
    pub review_at_ms: Option<i64>,
    pub created_at_ms: i64,
    pub updated_at_ms: i64,
}

/// Immutable snapshot appended to `revisions` whenever a decision or note
/// changes. `snapshot` is Markdown so history renders with the same renderer
/// as everything else.
#[derive(Debug, Clone)]
pub struct Revision {
    pub id: Uuid,
    /// `decision` | `note`
    pub entity_type: String,
    pub entity_id: Uuid,
    pub snapshot: String,
    pub created_at_ms: i64,
}
