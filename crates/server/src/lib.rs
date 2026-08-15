//! Server library: application wiring and the repository layer.

pub mod error;
pub mod repository;
pub mod routes;

use std::sync::Arc;

use axum::Router;
use axum::routing::get;

use crate::repository::Repository;

/// Shared application state handed to every handler.
#[derive(Clone)]
pub struct AppState {
    pub repo: Arc<dyn Repository>,
    /// Set once TLS is active so session cookies get the `Secure` flag.
    pub secure_cookies: bool,
}

/// Build the Axum router (plain HTTP; cookies without the `Secure` flag).
pub fn app(repo: Arc<dyn Repository>) -> Router {
    let state = AppState {
        repo,
        secure_cookies: false,
    };
    Router::new()
        .route("/health", get(routes::health))
        .with_state(state)
}

/// Build the router for HTTPS serving: session cookies carry the `Secure`
/// flag.
pub fn app_secure(repo: Arc<dyn Repository>) -> Router {
    let state = AppState {
        repo,
        secure_cookies: true,
    };
    Router::new()
        .route("/health", get(routes::health))
        .with_state(state)
}
