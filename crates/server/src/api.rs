//! Versioned JSON API (`/api/v1`) for native clients (Flutter) and future web
//! migration. Handlers here are thin wrappers over the existing repository and
//! domain logic so authorization, validation and revision behaviour stay shared.

use axum::extract::{Path, Query, State};
use axum::http::{HeaderMap, StatusCode, header};
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, post};

use axum::{Json, Router};
use causelog_model::{Decision, DecisionOption, Goal, Note, Project, User};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::AppState;
use crate::auth::{self, AuthUser};
use crate::error::ApiError;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/capabilities", get(capabilities))
        .route("/setup/status", get(setup_status))
        .route("/setup", post(setup))
        .route("/auth/register", post(register))
        .route("/auth/login", post(login))
        .route("/auth/logout", post(logout))
        .route("/session", get(session))
        .route("/projects", get(list_projects).post(create_project))
        .route(
            "/projects/{id}",
            get(get_project).patch(update_project).delete(delete_project),
        )
        .route(
            "/projects/{id}/members",
            get(list_project_members).post(add_project_member),
        )
        .route(
            "/projects/{id}/members/{user_id}",
            delete(remove_project_member),
        )
        .route(
            "/projects/{id}/goals",
            get(list_goals).post(create_goal),
        )
        .route(
            "/goals/{id}",
            get(get_goal).patch(update_goal).delete(delete_goal),
        )
        .route(
            "/projects/{id}/decisions",
            get(list_decisions).post(create_decision),
        )
        .route(
            "/decisions/{id}",
            get(get_decision)
                .patch(update_decision)
                .delete(delete_decision),
        )
        .route("/decisions/{id}/resolve", post(resolve_decision))
        .route("/decisions/{id}/revisions", get(list_decision_revisions))
        .route(
            "/projects/{id}/experiments",
            get(list_experiments).post(create_experiment),
        )
        .route(
            "/experiments/{id}",
            get(get_experiment)
                .patch(update_experiment)
                .delete(delete_experiment),
        )
        .route("/experiments/{id}/events", post(create_experiment_event))
        .route(
            "/experiments/{id}/events/{event_id}",
            delete(delete_experiment_event),
        )
        .route("/experiments/{id}/extract", post(extract_lesson))
        .route(
            "/projects/{id}/notes",
            get(list_notes).post(create_note),
        )
        .route(
            "/notes/{id}",
            get(get_note).patch(update_note).delete(delete_note),
        )
        .route("/notes/{id}/revisions", get(list_note_revisions))
        .route("/projects/{id}/links", post(create_link))
        .route("/projects/{id}/links/{link_id}", delete(delete_link))
        .route("/capture", post(capture))
        .route("/search", get(search))
        .route("/projects/{id}/timeline", get(get_timeline))
        .route("/projects/{id}/activity", get(get_activity))
        .route("/projects/{id}/graph", get(get_graph))
        .route("/projects/{id}/stats", get(get_project_stats))
        .route("/projects/{id}/exports", get(get_exports_manifest))
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#[derive(Debug, Deserialize, Default)]
struct CsrfBody {
    csrf_token: Option<String>,
}

#[derive(Debug, Deserialize, Default)]
struct PageQuery {
    page: Option<u32>,
    per_page: Option<u32>,
}

#[derive(Debug, Serialize)]
struct PageInfo {
    page: u32,
    per_page: u32,
    total: usize,
    total_pages: u32,
}

fn paginate<T: Clone>(items: Vec<T>, q: &PageQuery) -> (Vec<T>, PageInfo) {
    let per_page = q.per_page.unwrap_or(50).clamp(1, 200);
    let page = q.page.unwrap_or(1).max(1);
    let total = items.len();
    let total_pages = ((total as u32) + per_page - 1) / per_page.max(1);
    let total_pages = total_pages.max(1);
    let start = ((page - 1) as usize).saturating_mul(per_page as usize);
    let page_items = if start >= total {
        Vec::new()
    } else {
        items[start..total.min(start + per_page as usize)].to_vec()
    };
    (
        page_items,
        PageInfo {
            page,
            per_page,
            total,
            total_pages,
        },
    )
}

fn parse_uuid_param(s: &str) -> Result<Uuid, ApiError> {
    Uuid::parse_str(s).map_err(|_| ApiError::bad_request("invalid id"))
}

async fn require_session(state: &AppState, headers: &HeaderMap) -> Result<AuthUser, ApiError> {
    auth::session_user(state, headers)
        .await
        .ok_or_else(ApiError::unauthorized)
}

async fn require_approved_user(state: &AppState, headers: &HeaderMap) -> Result<AuthUser, ApiError> {
    let auth_user = require_session(state, headers).await?;
    if !auth::is_approved(&auth_user.user) {
        return Err(ApiError::forbidden());
    }
    Ok(auth_user)
}

fn require_csrf(headers: &HeaderMap, csrf_token: Option<&str>, auth_user: &AuthUser) -> Result<(), ApiError> {
    auth::verify_csrf_form(headers, csrf_token, &auth_user.csrf_token)
}

async fn require_project_member_api(
    state: &AppState,
    user: &User,
    project_id: Uuid,
) -> Result<Project, ApiError> {
    let project = state
        .repo
        .find_project(project_id)
        .await?
        .ok_or_else(|| ApiError::not_found("project not found"))?;
    if auth::is_admin(user) {
        return Ok(project);
    }
    if state.repo.is_project_member(user.id, project_id).await? {
        return Ok(project);
    }
    Err(ApiError::forbidden())
}

fn api_user(user: &User) -> ApiUser {
    ApiUser {
        id: user.id,
        username: user.username.clone(),
        display_name: user.display_name.clone(),
        role: user.role.clone(),
        approved: user.approved,
        created_at_ms: user.created_at_ms,
    }
}

// ---------------------------------------------------------------------------
// DTOs
// ---------------------------------------------------------------------------

#[derive(Debug, Serialize)]
struct ApiUser {
    id: Uuid,
    username: String,
    display_name: String,
    role: String,
    approved: bool,
    created_at_ms: i64,
}

#[derive(Debug, Serialize)]
struct SessionResponse {
    user: ApiUser,
    csrf_token: String,
}

#[derive(Debug, Serialize)]
struct Capabilities {
    api_version: &'static str,
    server_version: &'static str,
    auth: AuthCapabilities,
    export_formats: Vec<&'static str>,
}

#[derive(Debug, Serialize)]
struct AuthCapabilities {
    mode: &'static str,
    csrf_header: &'static str,
    session_cookie: &'static str,
}

#[derive(Debug, Serialize)]
struct SetupStatus {
    setup_required: bool,
}

#[derive(Debug, Deserialize)]
struct SetupRequest {
    username: String,
    display_name: Option<String>,
    password: String,
}

#[derive(Debug, Deserialize)]
struct RegisterRequest {
    username: String,
    display_name: Option<String>,
    password: String,
}

#[derive(Debug, Deserialize)]
struct LoginRequest {
    username: String,
    password: String,
}

// ---------------------------------------------------------------------------
// System / auth
// ---------------------------------------------------------------------------

async fn capabilities() -> Json<Capabilities> {
    Json(Capabilities {
        api_version: "v1",
        server_version: env!("CARGO_PKG_VERSION"),
        auth: AuthCapabilities {
            mode: "cookie_csrf",
            csrf_header: "X-CSRF-Token",
            session_cookie: auth::SESSION_COOKIE,
        },
        export_formats: vec!["json", "md", "html", "zip", "odp"],
    })
}

async fn setup_status(State(state): State<AppState>) -> Result<Json<SetupStatus>, ApiError> {
    let complete = state.repo.is_setup_complete().await?;
    Ok(Json(SetupStatus {
        setup_required: !complete,
    }))
}

async fn setup(
    State(state): State<AppState>,
    Json(body): Json<SetupRequest>,
) -> Result<Response, ApiError> {
    if state.repo.is_setup_complete().await? {
        return Err(ApiError::conflict("setup already complete"));
    }
    let username = body.username.trim();
    let display = body
        .display_name
        .as_deref()
        .unwrap_or(username)
        .trim();
    if username.is_empty() || body.password.len() < 8 {
        return Err(ApiError::bad_request(
            "username required and password must be at least 8 characters",
        ));
    }
    let hash = auth::hash_password(&body.password)?;
    let user = state
        .repo
        .create_first_user(username, display, &hash)
        .await?;
    let session = state.repo.create_session(user.id).await?;
    let cookie = auth::set_session_cookie_secure(&session.token, state.secure_cookies);
    let resp = Json(SessionResponse {
        user: api_user(&user),
        csrf_token: session.csrf,
    });
    Ok((StatusCode::CREATED, [(header::SET_COOKIE, cookie)], resp).into_response())
}

async fn register(
    State(state): State<AppState>,
    Json(body): Json<RegisterRequest>,
) -> Result<Response, ApiError> {
    let username = body.username.trim();
    let display = body
        .display_name
        .as_deref()
        .unwrap_or(username)
        .trim();
    if username.is_empty() || body.password.len() < 8 {
        return Err(ApiError::bad_request(
            "username required and password must be at least 8 characters",
        ));
    }
    let hash = auth::hash_password(&body.password)?;
    state
        .repo
        .create_user(username, display, &hash)
        .await?;
    Ok((
        StatusCode::CREATED,
        Json(serde_json::json!({ "pending_approval": true })),
    )
        .into_response())
}

async fn login(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(body): Json<LoginRequest>,
) -> Result<Response, ApiError> {
    let ip = headers
        .get("x-forwarded-for")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown")
        .to_string();
    if state.login_limiter.is_rate_limited(&ip) {
        return Err(ApiError::rate_limited());
    }
    let user = state
        .repo
        .find_user_by_username(body.username.trim())
        .await?;
    let Some(user) = user else {
        return Err(ApiError::unauthorized());
    };
    if !auth::verify_password(&user.password_hash, &body.password) {
        return Err(ApiError::unauthorized());
    }
    if !auth::is_approved(&user) {
        return Err(ApiError::forbidden());
    }
    let session = state.repo.create_session(user.id).await?;
    let cookie = auth::set_session_cookie_secure(&session.token, state.secure_cookies);
    let resp = Json(SessionResponse {
        user: api_user(&user),
        csrf_token: session.csrf,
    });
    Ok(([(header::SET_COOKIE, cookie)], resp).into_response())
}

async fn logout(
    State(state): State<AppState>,
    headers: HeaderMap,
    body: Option<Json<CsrfBody>>,
) -> Result<Response, ApiError> {
    let auth_user = require_session(&state, &headers).await?;
    let csrf = body.as_ref().and_then(|b| b.csrf_token.as_deref());
    require_csrf(&headers, csrf, &auth_user)?;
    if let Some(token) = auth::cookie(&headers, auth::SESSION_COOKIE) {
        let _ = state.repo.delete_session(&token).await;
    }
    let clear = auth::clear_session_cookie_secure(state.secure_cookies);
    Ok((StatusCode::NO_CONTENT, [(header::SET_COOKIE, clear)]).into_response())
}

async fn session(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<SessionResponse>, ApiError> {
    let auth_user = require_session(&state, &headers).await?;
    Ok(Json(SessionResponse {
        user: api_user(&auth_user.user),
        csrf_token: auth_user.csrf_token,
    }))
}

// ---------------------------------------------------------------------------
// Projects
// ---------------------------------------------------------------------------

#[derive(Debug, Deserialize)]
struct ProjectCreateRequest {
    csrf_token: Option<String>,
    title: String,
    summary: Option<String>,
    status: Option<String>,
}

#[derive(Debug, Deserialize)]
struct ProjectUpdateRequest {
    csrf_token: Option<String>,
    title: Option<String>,
    summary: Option<String>,
    status: Option<String>,
}

#[derive(Debug, Serialize)]
struct ProjectPageResponse {
    items: Vec<Project>,
    page: PageInfo,
}

async fn list_projects(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(q): Query<PageQuery>,
) -> Result<Json<ProjectPageResponse>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let mut projects = if auth::is_admin(&auth_user.user) {
        state.repo.list_projects().await?
    } else {
        state.repo.list_projects_for_user(auth_user.user.id).await?
    };
    projects.sort_by(|a, b| b.updated_at_ms.cmp(&a.updated_at_ms));
    let (items, page) = paginate(projects, &q);
    Ok(Json(ProjectPageResponse { items, page }))
}

async fn create_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(body): Json<ProjectCreateRequest>,
) -> Result<Response, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let title = body.title.trim();
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    let status = body.status.as_deref().unwrap_or("active");
    if !matches!(status, "active" | "paused" | "archived") {
        return Err(ApiError::bad_request("invalid project status"));
    }
    let project = state
        .repo
        .create_project(
            title,
            body.summary.as_deref().unwrap_or("").trim(),
            status,
            Some(auth_user.user.id),
        )
        .await?;
    Ok((StatusCode::CREATED, Json(project)).into_response())
}

async fn get_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Json<Project>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&id)?;
    let project = require_project_member_api(&state, &auth_user.user, pid).await?;
    Ok(Json(project))
}

async fn update_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Json(body): Json<ProjectUpdateRequest>,
) -> Result<Json<Project>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let pid = parse_uuid_param(&id)?;
    let project = require_project_member_api(&state, &auth_user.user, pid).await?;
    let title = body.title.as_deref().unwrap_or(&project.title).trim();
    let summary = body.summary.as_deref().unwrap_or(&project.summary).trim();
    let status = body.status.as_deref().unwrap_or(&project.status);
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    if !matches!(status, "active" | "paused" | "archived") {
        return Err(ApiError::bad_request("invalid project status"));
    }
    state
        .repo
        .update_project(pid, title, summary, status)
        .await?;
    let updated = state
        .repo
        .find_project(pid)
        .await?
        .ok_or_else(|| ApiError::not_found("project not found"))?;
    Ok(Json(updated))
}

async fn delete_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    body: Option<Json<CsrfBody>>,
) -> Result<StatusCode, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let csrf = body.as_ref().and_then(|b| b.csrf_token.as_deref());
    require_csrf(&headers, csrf, &auth_user)?;
    let pid = parse_uuid_param(&id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    state.repo.delete_project(pid).await?;
    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Serialize)]
struct ProjectMemberInfo {
    user: ApiUser,
    role: String,
}

async fn list_project_members(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let members = state.repo.list_project_members(pid).await?;
    let items: Vec<ProjectMemberInfo> = members
        .into_iter()
        .map(|(u, role)| ProjectMemberInfo {
            user: api_user(&u),
            role,
        })
        .collect();
    Ok(Json(serde_json::json!({ "items": items })))
}

#[derive(Debug, Deserialize)]
struct ProjectMemberAddRequest {
    csrf_token: Option<String>,
    user_id: Uuid,
    role: Option<String>,
}

async fn add_project_member(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Json(body): Json<ProjectMemberAddRequest>,
) -> Result<StatusCode, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let pid = parse_uuid_param(&id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    // Only admin or project owner may add members
    if !auth::is_admin(&auth_user.user) {
        let role = state
            .repo
            .user_project_role(auth_user.user.id, pid)
            .await?;
        if role.as_deref() != Some("owner") {
            return Err(ApiError::forbidden());
        }
    }
    let role = body.role.as_deref().unwrap_or("member");
    if !matches!(role, "owner" | "member") {
        return Err(ApiError::bad_request("invalid member role"));
    }
    state.repo.add_project_member(pid, body.user_id, role).await?;
    Ok(StatusCode::NO_CONTENT)
}

async fn remove_project_member(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((id, user_id)): Path<(String, String)>,
    body: Option<Json<CsrfBody>>,
) -> Result<StatusCode, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let csrf = body.as_ref().and_then(|b| b.csrf_token.as_deref());
    require_csrf(&headers, csrf, &auth_user)?;
    let pid = parse_uuid_param(&id)?;
    let uid = parse_uuid_param(&user_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    if !auth::is_admin(&auth_user.user) {
        let role = state
            .repo
            .user_project_role(auth_user.user.id, pid)
            .await?;
        if role.as_deref() != Some("owner") {
            return Err(ApiError::forbidden());
        }
    }
    state.repo.remove_project_member(pid, uid).await?;
    Ok(StatusCode::NO_CONTENT)
}

// ---------------------------------------------------------------------------
// Goals
// ---------------------------------------------------------------------------

#[derive(Debug, Deserialize)]
struct GoalCreateRequest {
    csrf_token: Option<String>,
    title: String,
    body: Option<String>,
    status: Option<String>,
    assigned_to: Option<Uuid>,
}

#[derive(Debug, Deserialize)]
struct GoalUpdateRequest {
    csrf_token: Option<String>,
    title: Option<String>,
    body: Option<String>,
    status: Option<String>,
    assigned_to: Option<Uuid>,
}

#[derive(Debug, Serialize)]
struct GoalPageResponse {
    items: Vec<Goal>,
    page: PageInfo,
}

#[derive(Debug, Deserialize, Default)]
struct StatusFilterQuery {
    page: Option<u32>,
    per_page: Option<u32>,
    status: Option<String>,
}

async fn list_goals(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(project_id): Path<String>,
    Query(q): Query<StatusFilterQuery>,
) -> Result<Json<GoalPageResponse>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let mut goals = state.repo.list_goals(pid).await?;
    if let Some(status) = q.status.as_deref() {
        goals.retain(|g| g.status == status);
    }
    let pq = PageQuery {
        page: q.page,
        per_page: q.per_page,
    };
    let (items, page) = paginate(goals, &pq);
    Ok(Json(GoalPageResponse { items, page }))
}

async fn create_goal(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(project_id): Path<String>,
    Json(body): Json<GoalCreateRequest>,
) -> Result<Response, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let title = body.title.trim();
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    let goal = state
        .repo
        .create_goal(
            pid,
            title,
            body.body.as_deref().unwrap_or("").trim(),
            Some(auth_user.user.id),
            body.assigned_to,
        )
        .await?;
    if let Some(status) = body.status.as_deref() {
        if matches!(status, "open" | "ongoing" | "done" | "dropped") && status != "open" {
            state.repo.update_goal_status(goal.id, status).await?;
        }
    }
    let goal = state
        .repo
        .find_goal(goal.id)
        .await?
        .ok_or_else(|| ApiError::not_found("goal not found"))?;
    Ok((StatusCode::CREATED, Json(goal)).into_response())
}

async fn get_goal(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Json<Goal>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let gid = parse_uuid_param(&id)?;
    let goal = state
        .repo
        .find_goal(gid)
        .await?
        .ok_or_else(|| ApiError::not_found("goal not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, goal.project_id).await?;
    Ok(Json(goal))
}

async fn update_goal(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Json(body): Json<GoalUpdateRequest>,
) -> Result<Json<Goal>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let gid = parse_uuid_param(&id)?;
    let goal = state
        .repo
        .find_goal(gid)
        .await?
        .ok_or_else(|| ApiError::not_found("goal not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, goal.project_id).await?;
    let title = body.title.as_deref().unwrap_or(&goal.title).trim();
    let body_text = body.body.as_deref().unwrap_or(&goal.body);
    let status = body.status.as_deref().unwrap_or(&goal.status);
    let assigned_to = body.assigned_to.or(goal.assigned_to);
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    if !matches!(status, "open" | "ongoing" | "done" | "dropped") {
        return Err(ApiError::bad_request("invalid goal status"));
    }
    state
        .repo
        .update_goal(gid, title, body_text, status, assigned_to)
        .await?;
    let goal = state
        .repo
        .find_goal(gid)
        .await?
        .ok_or_else(|| ApiError::not_found("goal not found"))?;
    Ok(Json(goal))
}

async fn delete_goal(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    body: Option<Json<CsrfBody>>,
) -> Result<StatusCode, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let csrf = body.as_ref().and_then(|b| b.csrf_token.as_deref());
    require_csrf(&headers, csrf, &auth_user)?;
    let gid = parse_uuid_param(&id)?;
    let goal = state
        .repo
        .find_goal(gid)
        .await?
        .ok_or_else(|| ApiError::not_found("goal not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, goal.project_id).await?;
    state.repo.delete_goal(gid).await?;
    Ok(StatusCode::NO_CONTENT)
}

// ---------------------------------------------------------------------------
// Stubs / minimal implementations for remaining M1 endpoints
// (to be expanded in follow-up work within the stage)
// ---------------------------------------------------------------------------

async fn list_decisions(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(project_id): Path<String>,
    Query(q): Query<StatusFilterQuery>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let mut items = state.repo.list_decisions(pid).await?;
    if let Some(status) = q.status.as_deref() {
        items.retain(|d| d.status == status);
    }
    let pq = PageQuery { page: q.page, per_page: q.per_page };
    let (items, page) = paginate(items, &pq);
    Ok(Json(serde_json::json!({ "items": items, "page": page })))
}

async fn get_decision(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Json<Decision>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let did = parse_uuid_param(&id)?;
    let decision = state.repo.find_decision(did).await?.ok_or_else(|| ApiError::not_found("decision not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, decision.project_id).await?;
    Ok(Json(decision))
}

#[derive(Debug, Deserialize)]
struct DecisionCreateRequest {
    csrf_token: Option<String>,
    title: String,
    context: Option<String>,
    goal_id: Option<Uuid>,
    options: Option<Vec<DecisionOption>>,
}

async fn create_decision(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(project_id): Path<String>,
    Json(body): Json<DecisionCreateRequest>,
) -> Result<Response, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let title = body.title.trim();
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    let options = body.options.unwrap_or_default();
    let decision = state
        .repo
        .create_decision(
            pid,
            body.goal_id,
            title,
            body.context.as_deref().unwrap_or("").trim(),
            &options,
            Some(auth_user.user.id),
        )
        .await?;
    Ok((StatusCode::CREATED, Json(decision)).into_response())
}

#[derive(Debug, Deserialize)]
struct DecisionUpdateRequest {
    csrf_token: Option<String>,
    title: Option<String>,
    context: Option<String>,
    options: Option<Vec<DecisionOption>>,
}

async fn update_decision(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Json(body): Json<DecisionUpdateRequest>,
) -> Result<Json<Decision>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let did = parse_uuid_param(&id)?;
    let d = state
        .repo
        .find_decision(did)
        .await?
        .ok_or_else(|| ApiError::not_found("decision not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, d.project_id).await?;
    let title = body.title.as_deref().unwrap_or(&d.title).trim().to_string();
    let context = body.context.as_deref().unwrap_or(&d.context).to_string();
    let options = body.options.unwrap_or_else(|| d.options.clone());
    if title.is_empty() {
        return Err(ApiError::bad_request("title is required"));
    }
    let d = state
        .repo
        .update_decision(did, &title, &context, &options)
        .await?;
    Ok(Json(d))
}

async fn delete_decision(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    body: Option<Json<CsrfBody>>,
) -> Result<StatusCode, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let csrf = body.as_ref().and_then(|b| b.csrf_token.as_deref());
    require_csrf(&headers, csrf, &auth_user)?;
    let did = parse_uuid_param(&id)?;
    let d = state.repo.find_decision(did).await?.ok_or_else(|| ApiError::not_found("decision not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, d.project_id).await?;
    state.repo.delete_decision(did).await?;
    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Deserialize)]
struct DecisionResolveRequest {
    csrf_token: Option<String>,
    status: String,
    decided_option: Option<String>,
    rationale: String,
    review_at_ms: Option<i64>,
}

async fn resolve_decision(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Json(body): Json<DecisionResolveRequest>,
) -> Result<Json<Decision>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    require_csrf(&headers, body.csrf_token.as_deref(), &auth_user)?;
    let did = parse_uuid_param(&id)?;
    let d = state.repo.find_decision(did).await?.ok_or_else(|| ApiError::not_found("decision not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, d.project_id).await?;
    if !matches!(body.status.as_str(), "decided" | "rejected") {
        return Err(ApiError::bad_request("invalid resolution status"));
    }
    let d = state
        .repo
        .resolve_decision(
            did,
            &body.status,
            body.decided_option,
            &body.rationale,
            body.review_at_ms,
        )
        .await?;
    Ok(Json(d))
}

async fn list_decision_revisions(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let did = parse_uuid_param(&id)?;
    let d = state.repo.find_decision(did).await?.ok_or_else(|| ApiError::not_found("decision not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, d.project_id).await?;
    let items = state.repo.list_revisions("decision", did).await?;
    Ok(Json(serde_json::json!({ "items": items })))
}

// ---------------------------------------------------------------------------
// Remaining endpoints: minimal placeholders returning 501 to make the surface
// explicit; to be completed within M1 follow-up commits.
// ---------------------------------------------------------------------------

fn not_implemented(name: &str) -> ApiError {
    ApiError::internal(format!("{name} not yet implemented in API v1"))
}

async fn list_experiments(State(state): State<AppState>, headers: HeaderMap, Path(project_id): Path<String>, Query(q): Query<PageQuery>) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let items = state.repo.list_experiments(pid).await?;
    let (items, page) = paginate(items, &q);
    Ok(Json(serde_json::json!({ "items": items, "page": page })))
}
async fn create_experiment(State(_state): State<AppState>, _headers: HeaderMap, Path(_project_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("create_experiment")) }
async fn get_experiment(State(state): State<AppState>, headers: HeaderMap, Path(id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let eid = parse_uuid_param(&id)?;
    let exp = state.repo.find_experiment(eid).await?.ok_or_else(|| ApiError::not_found("experiment not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, exp.project_id).await?;
    let events = state.repo.list_events(eid).await?;
    Ok(Json(serde_json::json!({ "experiment": exp, "events": events })))
}
async fn update_experiment(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("update_experiment")) }
async fn delete_experiment(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, _body: Option<Json<CsrfBody>>) -> Result<StatusCode, ApiError> { Err(not_implemented("delete_experiment")) }
async fn create_experiment_event(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("create_experiment_event")) }
async fn delete_experiment_event(State(_state): State<AppState>, _headers: HeaderMap, Path((_id,_eid)): Path<(String,String)>, _body: Option<Json<CsrfBody>>) -> Result<StatusCode, ApiError> { Err(not_implemented("delete_experiment_event")) }
async fn extract_lesson(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("extract_lesson")) }

async fn list_notes(State(state): State<AppState>, headers: HeaderMap, Path(project_id): Path<String>, Query(q): Query<PageQuery>) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let pid = parse_uuid_param(&project_id)?;
    let _ = require_project_member_api(&state, &auth_user.user, pid).await?;
    let items = state.repo.list_notes(pid).await?;
    let (items, page) = paginate(items, &q);
    Ok(Json(serde_json::json!({ "items": items, "page": page })))
}
async fn create_note(State(_state): State<AppState>, _headers: HeaderMap, Path(_project_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("create_note")) }
async fn get_note(State(state): State<AppState>, headers: HeaderMap, Path(id): Path<String>) -> Result<Json<Note>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let nid = parse_uuid_param(&id)?;
    let note = state.repo.find_note(nid).await?.ok_or_else(|| ApiError::not_found("note not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, note.project_id).await?;
    Ok(Json(note))
}
async fn update_note(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("update_note")) }
async fn delete_note(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>, _body: Option<Json<CsrfBody>>) -> Result<StatusCode, ApiError> { Err(not_implemented("delete_note")) }
async fn list_note_revisions(State(state): State<AppState>, headers: HeaderMap, Path(id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> {
    let auth_user = require_approved_user(&state, &headers).await?;
    let nid = parse_uuid_param(&id)?;
    let note = state.repo.find_note(nid).await?.ok_or_else(|| ApiError::not_found("note not found"))?;
    let _ = require_project_member_api(&state, &auth_user.user, note.project_id).await?;
    let items = state.repo.list_revisions("note", nid).await?;
    Ok(Json(serde_json::json!({ "items": items })))
}

async fn create_link(State(_state): State<AppState>, _headers: HeaderMap, Path(_project_id): Path<String>, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("create_link")) }
async fn delete_link(State(_state): State<AppState>, _headers: HeaderMap, Path((_project_id,_link_id)): Path<(String,String)>, _body: Option<Json<CsrfBody>>) -> Result<StatusCode, ApiError> { Err(not_implemented("delete_link")) }
async fn capture(State(_state): State<AppState>, _headers: HeaderMap, Json(_body): Json<serde_json::Value>) -> Result<Response, ApiError> { Err(not_implemented("capture")) }

async fn search(State(_state): State<AppState>, _headers: HeaderMap, Query(_q): Query<serde_json::Value>) -> Result<Json<serde_json::Value>, ApiError> { Err(not_implemented("search")) }
async fn get_timeline(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> { Err(not_implemented("timeline")) }
async fn get_activity(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> { Err(not_implemented("activity")) }
async fn get_graph(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> { Err(not_implemented("graph")) }
async fn get_project_stats(State(_state): State<AppState>, _headers: HeaderMap, Path(_id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> { Err(not_implemented("stats")) }
async fn get_exports_manifest(State(_state): State<AppState>, _headers: HeaderMap, Path(id): Path<String>) -> Result<Json<serde_json::Value>, ApiError> {
    let pid = parse_uuid_param(&id)?;
    let base = format!("/projects/{pid}/export");
    Ok(Json(serde_json::json!({
        "items": [
            {"format":"json","url":format!("{base}.json"),"content_type":"application/json","description":"Canonical JSON snapshot"},
            {"format":"md","url":format!("{base}.md"),"content_type":"application/zip","description":"Markdown export (ZIP)"},
            {"format":"html","url":format!("{base}.html"),"content_type":"application/zip","description":"Offline HTML site (ZIP)"},
            {"format":"zip","url":format!("{base}.zip"),"content_type":"application/zip","description":"Full archive bundle"},
            {"format":"odp","url":format!("{base}.odp"),"content_type":"application/vnd.oasis.opendocument.presentation","description":"Slideshow"}
        ]
    })))
}
