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
        .route("/dashboard", get(pages::dashboard_page))
        .route(
            "/projects",
            get(pages::dashboard_page).post(pages::project_create),
        )
        .route(
            "/projects/{id}",
            get(pages::project_page).post(pages::project_update),
        )
        .route("/projects/{id}/delete", post(pages::project_delete))
        .route(
            "/projects/{id}/goals",
            get(pages::project_goals_page).post(pages::goal_create),
        )
        .route("/projects/{id}/goals/{goal_id}", post(pages::goal_update))
        .route(
            "/projects/{id}/goals/{goal_id}/delete",
            post(pages::goal_delete),
        )
        .route(
            "/projects/{id}/decisions",
            get(pages::project_decisions_page).post(pages::decision_create),
        )
        .route(
            "/decisions/{id}",
            get(pages::decision_page).post(pages::decision_update),
        )
        .route("/decisions/{id}/resolve", post(pages::decision_resolve))
        .route("/decisions/{id}/delete", post(pages::decision_delete))
        .route(
            "/projects/{id}/experiments",
            get(pages::project_experiments_page).post(pages::experiment_create),
        )
        .route("/projects/{id}/timeline", get(pages::timeline_page))
        .route(
            "/experiments/{id}",
            get(pages::experiment_page).post(pages::experiment_update),
        )
        .route("/experiments/{id}/delete", post(pages::experiment_delete))
        .route("/experiments/{id}/events", post(pages::event_create))
        .route("/experiments/{id}/extract", post(pages::note_extract))
        .route(
            "/experiments/{id}/events/{event_id}/delete",
            post(pages::event_delete),
        )
        .route(
            "/projects/{id}/notes",
            get(pages::project_notes_page).post(pages::note_create),
        )
        .route(
            "/notes/{id}",
            get(pages::note_page).post(pages::note_update),
        )
        .route("/notes/{id}/delete", post(pages::note_delete))
        .route("/projects/{id}/links", post(pages::link_create))
        .route(
            "/projects/{id}/links/{link_id}/delete",
            post(pages::link_delete),
        )
        .route("/projects/{id}/graph", get(pages::graph_page))
        .route("/search", get(pages::search_page))
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
