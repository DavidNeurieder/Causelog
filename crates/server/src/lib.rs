//! Server library: application wiring and the repository layer.

pub mod auth;
pub mod error;
pub mod pages;
pub mod repository;
pub mod routes;

use std::sync::Arc;

use axum::Router;
use axum::routing::{get, post};

use crate::repository::Repository;

/// Shared application state handed to every handler.
#[derive(Clone)]
pub struct AppState {
    pub repo: Arc<dyn Repository>,
    /// Set once TLS is active so session cookies get the `Secure` flag.
    pub secure_cookies: bool,
}

fn router(state: AppState) -> Router {
    Router::new()
        .route("/", get(pages::home_page))
        .route("/setup", get(pages::setup_page).post(pages::setup_form))
        .route("/login", get(pages::login_page).post(pages::login_form))
        .route("/logout", post(pages::logout_form))
        .route("/static/{name}", get(pages::static_file))
        .route("/health", get(routes::health))
        .with_state(state)
}

/// Build the Axum router (plain HTTP; cookies without the `Secure` flag).
pub fn app(repo: Arc<dyn Repository>) -> Router {
    router(AppState {
        repo,
        secure_cookies: false,
    })
}

/// Build the router for HTTPS serving: session cookies carry the `Secure`
/// flag.
pub fn app_secure(repo: Arc<dyn Repository>) -> Router {
    router(AppState {
        repo,
        secure_cookies: true,
    })
}
