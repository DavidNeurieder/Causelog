//! Kaizen server errors: a single repository error type plus a JSON envelope
//! for API handlers (mirroring Forgepost). Page errors arrive with templates.

use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};

use crate::repository::RepositoryError;

#[derive(Debug)]
pub struct ApiError(pub RepositoryError);

impl ApiError {
    pub fn unauthorized() -> Self {
        Self(RepositoryError::Unauthorized)
    }
    pub fn forbidden() -> Self {
        Self(RepositoryError::Forbidden)
    }
    pub fn bad_request(msg: impl Into<String>) -> Self {
        Self(RepositoryError::InvalidInput(msg.into()))
    }
    pub fn conflict(msg: impl Into<String>) -> Self {
        Self(RepositoryError::Conflict(msg.into()))
    }
    pub fn status_and_message(&self) -> (StatusCode, String) {
        match &self.0 {
            RepositoryError::NotFound(m) => (StatusCode::NOT_FOUND, m.clone()),
            RepositoryError::Unauthorized => (StatusCode::UNAUTHORIZED, "unauthorized".into()),
            RepositoryError::Forbidden => (StatusCode::FORBIDDEN, "forbidden".into()),
            RepositoryError::InvalidInput(m) => (StatusCode::BAD_REQUEST, m.clone()),
            RepositoryError::Conflict(m) => (StatusCode::CONFLICT, m.clone()),
            RepositoryError::RateLimited => (StatusCode::TOO_MANY_REQUESTS, "rate limited".into()),
            RepositoryError::Io(_) => (StatusCode::INTERNAL_SERVER_ERROR, "io error".into()),
            RepositoryError::Uuid(_) => (StatusCode::BAD_REQUEST, "invalid id".into()),
            RepositoryError::Database(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()),
            RepositoryError::Migration(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()),
        }
    }
}

impl From<RepositoryError> for ApiError {
    fn from(err: RepositoryError) -> Self {
        Self(err)
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let (status, message) = self.status_and_message();
        (status, Json(serde_json::json!({ "error": message }))).into_response()
    }
}
