//! Server-rendered pages (single binary): home, setup, login, logout, and
//! static assets.
//!
//! Pages use POST-REDIRECT-GET: mutating forms redirect to the page with a
//! `?flash=key` so messages survive the reload and a refresh never resubmits
//! the form. All mutating forms carry a hidden `csrf_token` field verified
//! against the session.

use askama::Template;
use axum::extract::{Form, Path, Query, State};
use axum::http::{HeaderMap, header};
use axum::response::{Html, IntoResponse, Redirect, Response};
use kaizen_content::now_ms;
use serde::Deserialize;

use crate::AppState;
use crate::auth;
use crate::error::ApiError;
use crate::repository::RepositoryError;

// ---------------------------------------------------------------------------
// Template structs
// ---------------------------------------------------------------------------

fn render(tpl: &impl Template) -> Result<Html<String>, askama::Error> {
    Ok(Html(tpl.render()?))
}

fn page(tpl: &impl Template) -> Result<Response, PageError> {
    Ok(render(tpl).map_err(PageError::from)?.into_response())
}

/// Page errors render as an HTML error page instead of the JSON envelope used
/// by the API routes.
pub(crate) struct PageError(pub ApiError);

impl PageError {
    fn render(self) -> Response {
        let (status, message) = self.0.status_and_message();
        let tpl = ErrorTemplate {
            authed: false,
            flash: String::new(),
            year: current_year(),
            display_name: String::new(),
            csrf_token: String::new(),
            status: status.as_u16().to_string(),
            message,
        };
        (
            status,
            render(&tpl).unwrap_or_else(|_| Html("<h1>Error</h1>".into())),
        )
            .into_response()
    }
}

impl From<ApiError> for PageError {
    fn from(err: ApiError) -> Self {
        Self(err)
    }
}

impl From<RepositoryError> for PageError {
    fn from(err: RepositoryError) -> Self {
        Self(ApiError(err))
    }
}

impl From<askama::Error> for PageError {
    fn from(err: askama::Error) -> Self {
        Self(ApiError::bad_request(format!("template error: {err}")))
    }
}

impl IntoResponse for PageError {
    fn into_response(self) -> Response {
        self.render()
    }
}

#[derive(Template)]
#[template(path = "setup.html")]
struct SetupTemplate {
    authed: bool,
    flash: String,
    year: u32,
    display_name: String,
    csrf_token: String,
    error: String,
}

#[derive(Template)]
#[template(path = "login.html")]
struct LoginTemplate {
    authed: bool,
    flash: String,
    year: u32,
    display_name: String,
    csrf_token: String,
    error: String,
}

#[derive(Template)]
#[template(path = "error.html")]
struct ErrorTemplate {
    authed: bool,
    flash: String,
    year: u32,
    display_name: String,
    csrf_token: String,
    status: String,
    message: String,
}

#[derive(Deserialize)]
pub(crate) struct FlashQuery {
    pub flash: Option<String>,
}

/// Seconds since the Unix epoch → civil date (Howard Hinnant's algorithm).
fn civil_from_days(days: i64) -> (i64, u32, u32) {
    let z = days + 719_468;
    let era = if z >= 0 { z } else { z - 146_096 } / 146_097;
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    (if m <= 2 { y + 1 } else { y }, m as u32, d as u32)
}

fn current_year() -> u32 {
    civil_from_days(now_ms().div_euclid(86_400_000)).0 as u32
}

fn flash_message(key: Option<&str>) -> String {
    match key {
        Some("logged_out") => "You have been logged out.".into(),
        Some("not_authorized") => "You need to be signed in to do that.".into(),
        _ => String::new(),
    }
}

// ---------------------------------------------------------------------------
// Home
// ---------------------------------------------------------------------------

/// Landing route: `/setup` when unset-up, `/login` when anonymous, otherwise
/// the dashboard (implemented in the next milestone).
pub(crate) async fn home_page(State(state): State<AppState>, headers: HeaderMap) -> Response {
    if !state.repo.is_setup_complete().await.unwrap_or(false) {
        return Redirect::to("/setup").into_response();
    }
    if auth::session_user(&state, &headers).await.is_none() {
        return Redirect::to("/login").into_response();
    }
    Redirect::to("/dashboard").into_response()
}

// ---------------------------------------------------------------------------
// Setup
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct SetupForm {
    username: String,
    display: String,
    password: String,
    confirm: String,
}

pub(crate) async fn setup_page(State(state): State<AppState>) -> Result<Response, PageError> {
    if state.repo.is_setup_complete().await? {
        return Ok(Redirect::to("/login").into_response());
    }
    page(&SetupTemplate {
        authed: false,
        flash: String::new(),
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error: String::new(),
    })
}

pub(crate) async fn setup_form(
    State(state): State<AppState>,
    Form(body): Form<SetupForm>,
) -> Result<Response, PageError> {
    let error = validate_setup(&body);
    if !error.is_empty() {
        return page(&SetupTemplate {
            authed: false,
            flash: String::new(),
            year: current_year(),
            display_name: String::new(),
            csrf_token: String::new(),
            error,
        });
    }
    if state.repo.is_setup_complete().await? {
        return Ok(Redirect::to("/login").into_response());
    }
    let hash = auth::hash_password(&body.password)?;
    let user = match state
        .repo
        .create_first_user(&body.username, &body.display, &hash)
        .await
    {
        Ok(user) => user,
        Err(RepositoryError::Conflict(msg)) => {
            return page(&SetupTemplate {
                authed: false,
                flash: String::new(),
                year: current_year(),
                display_name: String::new(),
                csrf_token: String::new(),
                error: msg,
            });
        }
        Err(e) => return Err(e.into()),
    };
    let session = state.repo.create_session(user.id).await?;
    let cookie = auth::set_session_cookie_secure(&session.token, state.secure_cookies);
    Ok(([(header::SET_COOKIE, cookie)], Redirect::to("/dashboard")).into_response())
}

fn validate_setup(body: &SetupForm) -> String {
    let username = body.username.trim();
    if username.is_empty()
        || !username
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_' || c == '-')
    {
        return "Username must use only lowercase letters, digits, '_' and '-'.".into();
    }
    if username.len() < 3 {
        return "Username must be at least 3 characters.".into();
    }
    if body.display.trim().is_empty() {
        return "Enter a display name.".into();
    }
    if body.password.len() < 8 {
        return "Password must be at least 8 characters.".into();
    }
    if body.password != body.confirm {
        return "Passwords do not match.".into();
    }
    String::new()
}

// ---------------------------------------------------------------------------
// Login / logout
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct LoginForm {
    username: String,
    password: String,
}

pub(crate) async fn login_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    if !state.repo.is_setup_complete().await? {
        return Ok(Redirect::to("/setup").into_response());
    }
    if auth::session_user(&state, &headers).await.is_some() {
        return Ok(Redirect::to("/dashboard").into_response());
    }
    page(&LoginTemplate {
        authed: false,
        flash: flash_message(flash.flash.as_deref()),
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error: String::new(),
    })
}

pub(crate) async fn login_form(
    State(state): State<AppState>,
    Form(body): Form<LoginForm>,
) -> Result<Response, PageError> {
    let username = body.username.trim();
    let error = match state.repo.find_user_by_username(username).await? {
        Some(user) if auth::verify_password(&user.password_hash, &body.password) => {
            let session = state.repo.create_session(user.id).await?;
            let cookie = auth::set_session_cookie_secure(&session.token, state.secure_cookies);
            return Ok(([(header::SET_COOKIE, cookie)], Redirect::to("/dashboard")).into_response());
        }
        _ => "invalid username or password".to_string(),
    };
    page(&LoginTemplate {
        authed: false,
        flash: String::new(),
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error,
    })
}

#[derive(Deserialize)]
pub(crate) struct CsrfForm {
    pub csrf_token: Option<String>,
}

pub(crate) async fn logout_form(
    State(state): State<AppState>,
    headers: HeaderMap,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(Redirect::to("/login").into_response());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    if let Some(token) = auth::cookie(&headers, auth::SESSION_COOKIE) {
        state.repo.delete_session(&token).await?;
    }
    Ok((
        [(
            header::SET_COOKIE,
            auth::clear_session_cookie_secure(state.secure_cookies),
        )],
        Redirect::to("/login?flash=logged_out"),
    )
        .into_response())
}

// ---------------------------------------------------------------------------
// Static assets
// ---------------------------------------------------------------------------

/// Embedded static assets so a single binary serves everything.
pub(crate) async fn static_file(Path(name): Path<String>) -> Result<Response, PageError> {
    let (body, content_type) = match name.as_str() {
        "app.css" => (include_str!("../static/app.css"), "text/css"),
        "favicon.svg" => (include_str!("../static/favicon.svg"), "image/svg+xml"),
        _ => {
            return Err(PageError(ApiError(RepositoryError::NotFound(
                "asset".into(),
            ))));
        }
    };
    Ok(([(header::CONTENT_TYPE, content_type)], body.to_string()).into_response())
}
