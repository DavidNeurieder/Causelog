//! Server library: application wiring and the repository layer.

pub mod auth;
pub mod error;
pub mod pages;
pub mod repository;
pub mod routes;

use std::collections::HashMap;
use std::sync::Arc;
use std::time::{Duration, Instant};

use axum::Router;
use axum::routing::{get, post};

use crate::repository::Repository;

/// Tracks failed login attempts per key (IP address).
pub(crate) struct RateLimiter {
    attempts: std::sync::Mutex<HashMap<String, (u32, Instant)>>,
    max_attempts: u32,
    window: Duration,
}

impl RateLimiter {
    pub fn new(max_attempts: u32, window: Duration) -> Self {
        Self {
            attempts: std::sync::Mutex::new(HashMap::new()),
            max_attempts,
            window,
        }
    }

    /// Returns `true` if the key has exceeded the allowed attempts.
    pub fn is_rate_limited(&self, key: &str) -> bool {
        let mut attempts = self.attempts.lock().unwrap();
        let now = Instant::now();
        let entry = attempts.entry(key.to_string()).or_insert((0, now));
        if now.duration_since(entry.1) > self.window {
            *entry = (1, now);
            return false;
        }
        entry.0 += 1;
        entry.0 > self.max_attempts
    }
}

/// Shared application state handed to every handler.
#[derive(Clone)]
pub struct AppState {
    pub repo: Arc<dyn Repository>,
    /// Set once TLS is active so session cookies get the `Secure` flag.
    pub secure_cookies: bool,
    pub(crate) login_limiter: Arc<RateLimiter>,
}

fn router(state: AppState) -> Router {
    Router::new()
        .route("/", get(pages::home_page))
        .route("/setup", get(pages::setup_page).post(pages::setup_form))
        .route(
            "/register",
            get(pages::register_page).post(pages::register_form),
        )
        .route("/login", get(pages::login_page).post(pages::login_form))
        .route("/logout", post(pages::logout_form))
        .route("/dashboard", get(pages::dashboard_page))
        .route("/statistics", get(pages::statistics_page))
        .route(
            "/projects",
            get(pages::dashboard_page).post(pages::project_create),
        )
        .route(
            "/projects/{id}",
            get(pages::project_page).post(pages::project_update),
        )
        .route("/api/status", post(pages::api_status_change))
        .route("/api/goals/{id}", post(pages::api_goal_update))
        .route("/api/notes/{id}", post(pages::api_note_update))
        .route("/api/experiments/{id}", post(pages::api_experiment_update))
        .route("/api/projects/{id}", post(pages::api_project_update))
        .route("/api/decisions/{id}", post(pages::api_decision_update))
        .route(
            "/api/decisions/{id}/resolve",
            post(pages::api_decision_resolve),
        )
        .route("/projects/{id}/delete", post(pages::project_delete))
        .route(
            "/projects/{id}/goals",
            get(pages::project_goals_page).post(pages::goal_create),
        )
        .route("/projects/{id}/goals/new", get(pages::goal_new_page))
        .route("/goals/{id}", get(pages::goal_page))
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
            "/projects/{id}/decisions/new",
            get(pages::decision_new_page),
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
        .route(
            "/projects/{id}/experiments/new",
            get(pages::experiment_new_page),
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
        .route("/projects/{id}/notes/new", get(pages::note_new_page))
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
        .route("/projects/{id}/stats", get(pages::project_stats_page))
        .route(
            "/projects/{id}/members",
            get(pages::project_members_page).post(pages::project_member_add),
        )
        .route(
            "/projects/{id}/members/{uid}/remove",
            post(pages::project_member_remove),
        )
        .route("/admin/users", get(pages::admin_users_page))
        .route("/admin/users/{id}/approve", post(pages::admin_user_approve))
        .route("/admin/users/{id}/reject", post(pages::admin_user_reject))
        .route("/admin/users/{id}/role", post(pages::admin_user_role))
        .route("/admin/users/{id}/delete", post(pages::admin_user_delete))
        .route(
            "/admin/users/{id}/add-to-project",
            post(pages::admin_user_add_to_project),
        )
        .route(
            "/admin/users/{id}/remove-from-project",
            post(pages::admin_user_remove_from_project),
        )
        .route(
            "/admin/settings",
            get(pages::admin_settings_page).post(pages::admin_settings_form),
        )
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
        login_limiter: Arc::new(RateLimiter::new(5, Duration::from_secs(900))),
    })
}

/// Build the router for HTTPS serving: session cookies carry the `Secure`
/// flag.
pub fn app_secure(repo: Arc<dyn Repository>) -> Router {
    router(AppState {
        repo,
        secure_cookies: true,
        login_limiter: Arc::new(RateLimiter::new(5, Duration::from_secs(900))),
    })
}
