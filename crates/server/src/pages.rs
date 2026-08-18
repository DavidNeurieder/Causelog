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
use axum::Json;
use causelog_content::{format_date_ms, now_ms, parse_date_ms, render_markdown};
use causelog_model::{Decision, DecisionOption, Experiment, Goal, Note, Project, User};
use serde::Deserialize;
use std::collections::HashMap;
use std::str::FromStr;
use std::sync::Arc;
use uuid::Uuid;

use crate::AppState;
use crate::auth;
use crate::error::ApiError;
use crate::repository::{
    DashboardCounts, GraphData, ProjectCounts, Repository, RepositoryError, SearchRow,
    TimelineEntry,
};

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
            flash_kind: "notice--info",
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
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    error: String,
    /// Re-submitted values so the form survives a failed attempt.
    username: String,
    display: String,
}

#[derive(Template)]
#[template(path = "login.html")]
struct LoginTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    error: String,
    /// Re-submitted username so a failed login keeps what you typed.
    username: String,
}

#[derive(Template)]
#[template(path = "register.html")]
struct RegisterTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    error: String,
    username: String,
    display: String,
}

#[derive(Template)]
#[template(path = "error.html")]
struct ErrorTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    status: String,
    message: String,
}

#[derive(Template)]
#[template(path = "dashboard.html")]
struct DashboardTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    projects: Vec<ProjectView>,
    /// Open the create-project form (after a rejected empty-title submit).
    create_open: bool,
    is_admin: bool,
}

#[derive(Template)]
#[template(path = "statistics.html")]
struct StatisticsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    counts: DashboardCounts,
}

/// User with their project memberships, for the admin users page.
struct UserWithProjects {
    user: User,
    projects: Vec<Project>,
}

#[derive(Template)]
#[template(path = "admin/users.html")]
struct AdminUsersTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    pending_with_projects: Vec<UserWithProjects>,
    approved_with_projects: Vec<UserWithProjects>,
    all_projects: Vec<Project>,
}

#[derive(Template)]
#[template(path = "admin/settings.html")]
struct AdminSettingsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
}

#[derive(Template)]
#[template(path = "board.html")]
struct BoardTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goals_open: Vec<GoalItemView>,
    goals_ongoing: Vec<GoalItemView>,
    goals_done: Vec<GoalItemView>,
    goals_dropped: Vec<GoalItemView>,
    decisions_open: Vec<DecisionItemView>,
    decisions_decided: Vec<DecisionItemView>,
    decisions_rejected: Vec<DecisionItemView>,
    experiments_planned: Vec<ExperimentItemView>,
    experiments_ongoing: Vec<ExperimentItemView>,
    experiments_done: Vec<ExperimentItemView>,
    experiments_abandoned: Vec<ExperimentItemView>,
}

#[derive(Template)]
#[template(path = "project/members.html")]
struct ProjectMembersTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    members: Vec<(User, String)>,
    all_users: Vec<User>,
    is_owner: bool,
}

#[derive(Template)]
#[template(path = "project.html")]
struct ProjectTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goals: Vec<GoalItemView>,
    decisions: Vec<DecisionItemView>,
    experiments: Vec<ExperimentItemView>,
    notes: Vec<Note>,
}

#[derive(Template)]
#[template(path = "stats.html")]
struct ProjectStatsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    counts: ProjectCounts,
    goals_done_pct: i64,
    decisions_resolved_pct: i64,
}

#[derive(Template)]
#[template(path = "goals.html")]
struct ProjectGoalsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goals: Vec<GoalItemView>,
}

#[derive(Template)]
#[template(path = "goal.html")]
struct GoalTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goal: Goal,
    body_html: String,
    created_by_name: String,
    assigned_to_name: String,
    goal_assigned_to_id: String,
    members: Vec<(User, String)>,
    decisions: Vec<DecisionItemView>,
    experiments: Vec<ExperimentItemView>,
}

#[derive(Template)]
#[template(path = "decisions.html")]
struct ProjectDecisionsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    decisions: Vec<DecisionItemView>,
}

#[derive(Template)]
#[template(path = "experiments.html")]
struct ProjectExperimentsTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    experiments: Vec<ExperimentItemView>,
}

#[derive(Template)]
#[template(path = "notes.html")]
struct ProjectNotesTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    notes: Vec<Note>,
}

#[derive(Template)]
#[template(path = "goal_new.html")]
struct GoalNewTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    members: Vec<(User, String)>,
}

#[derive(Template)]
#[template(path = "decision_new.html")]
struct DecisionNewTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goals: Vec<Goal>,
}

#[derive(Template)]
#[template(path = "experiment_new.html")]
struct ExperimentNewTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goals: Vec<Goal>,
    decisions: Vec<DecisionItemView>,
}

#[derive(Template)]
#[template(path = "note_new.html")]
struct NoteNewTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
}

/// Experiment row on a project page.
struct ExperimentItemView {
    id: String,
    title: String,
    status: String,
}

/// Goal row on a project page, with its details rendered as Markdown.
struct GoalItemView {
    id: String,
    title: String,
    status: String,
    body_html: String,
    assigned_to_name: String,
}

#[derive(Template)]
#[template(path = "experiment.html")]
struct ExperimentTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    experiment: Experiment,
    view: ExperimentView,
    created_by_name: String,
    events: Vec<EventView>,
}

/// Rendered display of an experiment; the edit form is pre-filled from raw
/// Markdown, so render the fields separately for display.
struct ExperimentView {
    started_at: String,
    ended_at: String,
    hypothesis_html: String,
    result_html: String,
    lesson_html: String,
    goal_title: String,
    decision_title: String,
}

struct EventView {
    id: String,
    kind: String,
    at: String,
    note_html: String,
}

#[derive(Template)]
#[template(path = "timeline.html")]
struct TimelineTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    entries: Vec<TimelineView>,
}

struct TimelineView {
    at: String,
    kind: String,
    note: String,
    experiment_id: String,
}

/// Decision row on a project page.
struct DecisionItemView {
    id: String,
    title: String,
    status: String,
    decided_label: String,
}

#[derive(Template)]
#[template(path = "decision.html")]
struct DecisionTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    goal_options: Vec<GoalOptionView>,
    decision: Decision,
    view: DecisionView,
    created_by_name: String,
    revisions: Vec<RevisionView>,
}

/// Rendered (HTML-safe) display of a decision, separate from the raw Markdown
/// used to pre-fill edit forms.
struct DecisionView {
    status: String,
    context_html: String,
    options: Vec<OptionView>,
    decided_label: String,
    rationale_html: String,
    decided_at: String,
    review_at: String,
    goal_title: String,
    opt1: EditOption,
    opt2: EditOption,
    opt3: EditOption,
}

struct OptionView {
    id: String,
    label: String,
    pros_html: String,
    cons_html: String,
}

struct RevisionView {
    created_at: String,
    html: String,
}

/// Pre-filled values for one option slot in the edit form (askama can't call
/// closures, so we pad the three slots in Rust).
struct EditOption {
    label: String,
    pros: String,
    cons: String,
}

/// One row of the "serves goal" select in the edit form.
struct GoalOptionView {
    id: String,
    title: String,
    selected: bool,
}

fn edit_option(options: &[DecisionOption], index: usize) -> EditOption {
    match options.get(index) {
        Some(o) => EditOption {
            label: o.label.clone(),
            pros: o.pros.clone(),
            cons: o.cons.clone(),
        },
        None => EditOption {
            label: String::new(),
            pros: String::new(),
            cons: String::new(),
        },
    }
}

/// Project row on the dashboard, with aggregate counts.
struct ProjectView {
    project: Project,
    counts: ProjectCounts,
}

/// One selectable entity in a "relate" form.
struct EntityChoiceView {
    type_name: String,
    id: String,
    label: String,
}

/// One explicit link, as shown on the graph page with a delete action.
struct LinkView {
    id: String,
    from_label: String,
    to_label: String,
    kind: String,
}

#[derive(Template)]
#[template(path = "note.html")]
struct NoteTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    note: Note,
    view: NoteView,
    created_by_name: String,
    revisions: Vec<RevisionView>,
}

struct NoteView {
    body_html: String,
    source_title: String,
    source_url: String,
}

#[derive(Template)]
#[template(path = "graph.html")]
struct GraphTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    project: Project,
    nodes: Vec<GraphNodeView>,
    implicit: Vec<GraphEdgeView>,
    links: Vec<LinkView>,
    link_entities: Vec<EntityChoiceView>,
}

struct GraphNodeView {
    node_type: String,
    title: String,
    url: String,
}

struct GraphEdgeView {
    from_label: String,
    to_label: String,
    kind: String,
}

#[derive(Template)]
#[template(path = "search.html")]
struct SearchTemplate {
    authed: bool,
    flash: String,
    flash_kind: &'static str,
    year: u32,
    display_name: String,
    csrf_token: String,
    query: String,
    results: Vec<SearchItemView>,
}

struct SearchItemView {
    url: String,
    title: String,
    entity_type: String,
    project_title: String,
    snippet_html: String,
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

/// Integer percentage of `part` within `total`; 0 when there is nothing to
/// measure yet.
fn percent(part: i64, total: i64) -> i64 {
    if total <= 0 { 0 } else { part * 100 / total }
}

/// Resolve a `created_by` user ID to a display name, falling back to "Unknown".
async fn creator_name(repo: &Arc<dyn Repository>, id: Option<Uuid>) -> String {
    match id {
        Some(uid) => match repo.find_user_by_id(uid).await {
            Ok(Some(user)) => user.display_name,
            _ => "Unknown".into(),
        },
        None => "Unknown".into(),
    }
}

/// Parse an optional assigned_to UUID string from a form field.
fn parse_assigned_to(val: &Option<String>) -> Option<Uuid> {
    val.as_ref()
        .map(|s| s.trim())
        .filter(|s| !s.is_empty())
        .and_then(|s| Uuid::from_str(s).ok())
}

fn flash_message(key: Option<&str>) -> String {
    match key {
        Some("logged_out") => "You have been logged out.".into(),
        Some("not_authorized") => "You need to be signed in to do that.".into(),
        Some("created") => "Project created.".into(),
        Some("updated") => "Changes saved.".into(),
        Some("deleted") => "Project deleted.".into(),
        Some("goal_created") => "Goal added.".into(),
        Some("goal_updated") => "Goal updated.".into(),
        Some("goal_deleted") => "Goal removed.".into(),
        Some("invalid_title") => "A title is required.".into(),
        Some("decision_created") => "Decision created.".into(),
        Some("decision_updated") => "Decision updated.".into(),
        Some("decision_resolved") => "Decision recorded.".into(),
        Some("decision_deleted") => "Decision deleted.".into(),
        Some("invalid_decision") => "Give the decision a title and at least one option.".into(),
        Some("approved") => "User approved.".into(),
        Some("role_updated") => "User role updated.".into(),
        Some("cannot_delete_self") => "You cannot delete your own account from here.".into(),
        Some("cannot_demote_last_admin") => "Cannot demote: this is the only admin.".into(),
        Some("cannot_delete_last_admin") => "Cannot delete: this is the only admin.".into(),
        Some("member_added") => "Member added.".into(),
        Some("member_removed") => "Member removed.".into(),
        Some("cannot_remove_last_owner") => "Cannot remove the last owner of a project.".into(),
        _ => String::new(),
    }
}

/// Flash message plus the notice style class that should render it.
fn flash_view(key: Option<&str>) -> (String, &'static str) {
    let kind = match key {
        None => "notice--info",
        Some(k) if k.contains("invalid") || k.starts_with("no_") || k.starts_with("cannot_") => {
            "notice--error"
        }
        Some("logged_out") | Some("not_authorized") => "notice--info",
        Some(_) => "notice--success",
    };
    (flash_message(key), kind)
}

fn not_found(msg: impl Into<String>) -> ApiError {
    ApiError(RepositoryError::NotFound(msg.into()))
}

fn parse_uuid(s: &str) -> Result<Uuid, ApiError> {
    Uuid::parse_str(s).map_err(|_| ApiError::bad_request("invalid id"))
}

fn login_redirect() -> Response {
    Redirect::to("/login?flash=not_authorized").into_response()
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
        flash_kind: "notice--info",
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error: String::new(),
        username: String::new(),
        display: String::new(),
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
            flash_kind: "notice--info",
            year: current_year(),
            display_name: String::new(),
            csrf_token: String::new(),
            error,
            username: body.username.trim().to_string(),
            display: body.display.trim().to_string(),
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
                flash_kind: "notice--info",
                year: current_year(),
                display_name: String::new(),
                csrf_token: String::new(),
                error: msg,
                username: body.username.trim().to_string(),
                display: body.display.trim().to_string(),
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
// Registration (self-signup, pending approval)
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct RegisterForm {
    username: String,
    display: String,
    password: String,
    confirm: String,
}

pub(crate) async fn register_page(
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
    page(&RegisterTemplate {
        authed: false,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error: String::new(),
        username: String::new(),
        display: String::new(),
    })
}

pub(crate) async fn register_form(
    State(state): State<AppState>,
    Form(body): Form<RegisterForm>,
) -> Result<Response, PageError> {
    let error = validate_register(&body);
    if !error.is_empty() {
        return page(&RegisterTemplate {
            authed: false,
            flash: String::new(),
            flash_kind: "notice--info",
            year: current_year(),
            display_name: String::new(),
            csrf_token: String::new(),
            error,
            username: body.username.trim().to_string(),
            display: body.display.trim().to_string(),
        });
    }
    let hash = auth::hash_password(&body.password)?;
    match state
        .repo
        .create_user(&body.username, &body.display, &hash)
        .await
    {
        Ok(_) => Ok(Redirect::to("/login?flash=registered").into_response()),
        Err(crate::repository::RepositoryError::Conflict(msg)) => page(&RegisterTemplate {
            authed: false,
            flash: String::new(),
            flash_kind: "notice--info",
            year: current_year(),
            display_name: String::new(),
            csrf_token: String::new(),
            error: msg,
            username: body.username.trim().to_string(),
            display: body.display.trim().to_string(),
        }),
        Err(e) => Err(e.into()),
    }
}

fn validate_register(body: &RegisterForm) -> String {
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
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error: String::new(),
        username: String::new(),
    })
}

pub(crate) async fn login_form(
    State(state): State<AppState>,
    Form(body): Form<LoginForm>,
) -> Result<Response, PageError> {
    let username = body.username.trim();
    let error = match state.repo.find_user_by_username(username).await? {
        Some(user) if auth::verify_password(&user.password_hash, &body.password) => {
            if !auth::is_approved(&user) {
                "your account is pending admin approval".to_string()
            } else {
                let session = state.repo.create_session(user.id).await?;
                let cookie = auth::set_session_cookie_secure(&session.token, state.secure_cookies);
                return Ok(
                    ([(header::SET_COOKIE, cookie)], Redirect::to("/dashboard")).into_response()
                );
            }
        }
        _ => "invalid username or password".to_string(),
    };
    page(&LoginTemplate {
        authed: false,
        flash: String::new(),
        flash_kind: "notice--info",
        year: current_year(),
        display_name: String::new(),
        csrf_token: String::new(),
        error,
        username: username.to_string(),
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
        "kanban.js" => (include_str!("../static/kanban.js"), "application/javascript"),
        "favicon.svg" => (include_str!("../static/favicon.svg"), "image/svg+xml"),
        _ => {
            return Err(PageError(ApiError(RepositoryError::NotFound(
                "asset".into(),
            ))));
        }
    };
    Ok(([(header::CONTENT_TYPE, content_type)], body.to_string()).into_response())
}

// ---------------------------------------------------------------------------
// Dashboard & projects
// ---------------------------------------------------------------------------

pub(crate) async fn dashboard_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    // Admin sees all projects; regular users see only projects they belong to.
    let projects = if auth::is_admin(&auth_user.user) {
        state.repo.list_projects().await?
    } else {
        state.repo.list_projects_for_user(auth_user.user.id).await?
    };
    let mut views = Vec::with_capacity(projects.len());
    for p in projects {
        let counts = state.repo.project_counts(p.id).await?;
        views.push(ProjectView { project: p, counts });
    }
    let is_admin = auth::is_admin(&auth_user.user);
    page(&DashboardTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        projects: views,
        create_open: flash.flash.as_deref() == Some("invalid_title"),
        is_admin,
    })
}

pub(crate) async fn statistics_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    let counts = state.repo.dashboard_counts().await?;
    page(&StatisticsTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        counts,
    })
}

#[derive(Deserialize)]
pub(crate) struct ProjectForm {
    pub csrf_token: Option<String>,
    title: String,
    summary: String,
    status: String,
}

pub(crate) async fn project_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Form(body): Form<ProjectForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    if body.title.trim().is_empty() {
        return Ok(Redirect::to("/dashboard?flash=invalid_title").into_response());
    }
    let project = state
        .repo
        .create_project(
            body.title.trim(),
            body.summary.trim(),
            "active",
            Some(auth_user.user.id),
        )
        .await?;
    Ok(Redirect::to(&format!("/projects/{}", project.id)).into_response())
}

pub(crate) async fn project_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let goals_raw = state.repo.list_goals(project.id).await?;
    let mut goals = Vec::with_capacity(goals_raw.len());
    for g in goals_raw {
        let assigned_to_name = creator_name(&state.repo, g.assigned_to).await;
        goals.push(GoalItemView {
            id: g.id.to_string(),
            title: g.title,
            status: g.status,
            body_html: render_markdown(&g.body),
            assigned_to_name,
        });
    }
    let decisions = state.repo.list_decisions(project.id).await?;
    let experiments = state.repo.list_experiments(project.id).await?;
    let notes = state.repo.list_notes(project.id).await?;
    page(&ProjectTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goals: goals.into_iter().take(5).collect(),
        decisions: decisions
            .into_iter()
            .take(5)
            .map(|d| {
                let decided_label = decided_label(&d);
                DecisionItemView {
                    id: d.id.to_string(),
                    title: d.title,
                    status: d.status,
                    decided_label,
                }
            })
            .collect(),
        experiments: experiments
            .into_iter()
            .take(5)
            .map(|e| ExperimentItemView {
                id: e.id.to_string(),
                title: e.title,
                status: e.status,
            })
            .collect(),
        notes: notes.into_iter().take(5).collect(),
    })
}

pub(crate) async fn project_stats_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let project_id = project.id;
    let counts: ProjectCounts = state.repo.project_counts(project_id).await?;
    let goals_done_pct = percent(counts.goals_done, counts.goals_total);
    let decisions_resolved_pct = percent(counts.decisions_decided, counts.decisions_total);
    page(&ProjectStatsTemplate {
        authed: true,
        flash: String::new(),
        flash_kind: "",
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        counts,
        goals_done_pct,
        decisions_resolved_pct,
    })
}

/// Load a project from its id in the URL, or render a 404 page.
async fn require_project(state: &AppState, id: &str) -> Result<Project, PageError> {
    let project_id = parse_uuid(id)?;
    let project = state
        .repo
        .find_project(project_id)
        .await?
        .ok_or_else(|| not_found("project"))?;
    Ok(project)
}

/// Check that the user is an admin or a member of the project.
/// Returns `Ok(())` if authorized, or a redirect response if not.
async fn require_member_or_admin(
    state: &AppState,
    user: &causelog_model::User,
    project_id: Uuid,
) -> Result<(), Response> {
    if auth::is_admin(user) {
        return Ok(());
    }
    if state
        .repo
        .is_project_member(user.id, project_id)
        .await
        .unwrap_or(false)
    {
        return Ok(());
    }
    Err(Redirect::to("/dashboard?flash=access_denied").into_response())
}

/// Load a project and verify the user is an admin or member.
async fn require_project_member(
    state: &AppState,
    id: &str,
    user: &causelog_model::User,
) -> Result<Project, PageError> {
    let project = require_project(state, id).await?;
    require_member_or_admin(state, user, project.id)
        .await
        .map_err(|_| ApiError::forbidden())?;
    Ok(project)
}

pub(crate) async fn project_goals_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let goals_raw = state.repo.list_goals(project.id).await?;
    let mut goals = Vec::with_capacity(goals_raw.len());
    for g in goals_raw {
        let assigned_to_name = creator_name(&state.repo, g.assigned_to).await;
        goals.push(GoalItemView {
            id: g.id.to_string(),
            title: g.title,
            status: g.status,
            body_html: render_markdown(&g.body),
            assigned_to_name,
        });
    }
    page(&ProjectGoalsTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goals,
    })
}

pub(crate) async fn project_decisions_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let decisions = state.repo.list_decisions(project.id).await?;
    page(&ProjectDecisionsTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        decisions: decisions
            .into_iter()
            .map(|d| {
                let decided_label = decided_label(&d);
                DecisionItemView {
                    id: d.id.to_string(),
                    title: d.title,
                    status: d.status,
                    decided_label,
                }
            })
            .collect(),
    })
}

pub(crate) async fn project_experiments_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let experiments = state.repo.list_experiments(project.id).await?;
    page(&ProjectExperimentsTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        experiments: experiments
            .into_iter()
            .map(|e| ExperimentItemView {
                id: e.id.to_string(),
                title: e.title,
                status: e.status,
            })
            .collect(),
    })
}

pub(crate) async fn project_notes_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let notes = state.repo.list_notes(project.id).await?;
    page(&ProjectNotesTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        notes,
    })
}

pub(crate) async fn goal_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let goal_id = parse_uuid(&id)?;
    let goal = state
        .repo
        .find_goal(goal_id)
        .await?
        .ok_or_else(|| not_found("goal"))?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, goal.project_id).await {
        return Ok(redirect);
    }
    let project = state
        .repo
        .find_project(goal.project_id)
        .await?
        .ok_or_else(|| not_found("project"))?;
    let decisions = state
        .repo
        .list_decisions(goal.project_id)
        .await?
        .into_iter()
        .filter(|d| d.goal_id == Some(goal.id))
        .map(|d| {
            let decided_label = decided_label(&d);
            DecisionItemView {
                id: d.id.to_string(),
                title: d.title,
                status: d.status,
                decided_label,
            }
        })
        .collect();
    let experiments = state
        .repo
        .list_experiments(goal.project_id)
        .await?
        .into_iter()
        .filter(|e| e.goal_id == Some(goal.id))
        .map(|e| ExperimentItemView {
            id: e.id.to_string(),
            title: e.title,
            status: e.status,
        })
        .collect();
    let body_html = render_markdown(&goal.body);
    let created_by_name = creator_name(&state.repo, goal.created_by).await;
    let assigned_to_name = creator_name(&state.repo, goal.assigned_to).await;
    let goal_assigned_to_id = goal
        .assigned_to
        .map(|id| id.to_string())
        .unwrap_or_default();
    let members = state
        .repo
        .list_project_members(goal.project_id)
        .await
        .unwrap_or_default();
    page(&GoalTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goal,
        body_html,
        created_by_name,
        assigned_to_name,
        goal_assigned_to_id,
        members,
        decisions,
        experiments,
    })
}

pub(crate) async fn goal_new_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let members = state
        .repo
        .list_project_members(project.id)
        .await
        .unwrap_or_default();
    page(&GoalNewTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        members,
    })
}

pub(crate) async fn decision_new_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let goals = state.repo.list_goals(project.id).await?;
    page(&DecisionNewTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goals,
    })
}

pub(crate) async fn experiment_new_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let goals = state.repo.list_goals(project.id).await?;
    let decisions = state
        .repo
        .list_decisions(project.id)
        .await?
        .into_iter()
        .map(|d| {
            let decided_label = decided_label(&d);
            DecisionItemView {
                id: d.id.to_string(),
                title: d.title,
                status: d.status,
                decided_label,
            }
        })
        .collect();
    page(&ExperimentNewTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goals,
        decisions,
    })
}

pub(crate) async fn note_new_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    page(&NoteNewTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
    })
}

pub(crate) async fn project_update(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<ProjectForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}?flash=invalid_title")).into_response(),
        );
    }
    let status = if matches!(body.status.as_str(), "active" | "paused" | "archived") {
        body.status.as_str()
    } else {
        "active"
    };
    state
        .repo
        .update_project(project_id, body.title.trim(), body.summary.trim(), status)
        .await?;
    Ok(Redirect::to(&format!("/projects/{project_id}?flash=updated")).into_response())
}

pub(crate) async fn project_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_project(project_id).await?;
    Ok(Redirect::to("/dashboard?flash=deleted").into_response())
}

#[derive(Deserialize)]
pub(crate) struct GoalForm {
    pub csrf_token: Option<String>,
    title: String,
    body: String,
    status: String,
    assigned_to: Option<String>,
}

pub(crate) async fn goal_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<GoalForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/goals?flash=invalid_title"))
                .into_response(),
        );
    }
    state
        .repo
        .create_goal(
            project_id,
            body.title.trim(),
            body.body.trim(),
            Some(auth_user.user.id),
            parse_assigned_to(&body.assigned_to),
        )
        .await?;
    Ok(Redirect::to(&format!("/projects/{project_id}/goals?flash=goal_created")).into_response())
}

pub(crate) async fn goal_update(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((project_id, goal_id)): Path<(String, String)>,
    Form(body): Form<GoalForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&project_id)?;
    let goal_id = parse_uuid(&goal_id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/goals?flash=invalid_title"))
                .into_response(),
        );
    }
    let status = if matches!(body.status.as_str(), "open" | "ongoing" | "done" | "dropped") {
        body.status.as_str()
    } else {
        "open"
    };
    state
        .repo
        .update_goal(
            goal_id,
            body.title.trim(),
            body.body.trim(),
            status,
            parse_assigned_to(&body.assigned_to),
        )
        .await?;
    Ok(Redirect::to(&format!("/goals/{goal_id}?flash=goal_updated")).into_response())
}

pub(crate) async fn goal_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((project_id, goal_id)): Path<(String, String)>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&project_id)?;
    let goal_id = parse_uuid(&goal_id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_goal(goal_id).await?;
    Ok(Redirect::to(&format!("/projects/{project_id}/goals?flash=goal_deleted")).into_response())
}

// ---------------------------------------------------------------------------
// Decisions
// ---------------------------------------------------------------------------

/// Label of the decided option, or an empty string.
fn decided_label(d: &Decision) -> String {
    d.decided_option
        .as_ref()
        .and_then(|id| d.options.iter().find(|o| &o.id == id))
        .map(|o| o.label.clone())
        .unwrap_or_default()
}

/// Build the option list from the create/edit form's slots, skipping blank
/// labels. Each slot is `(label, pros, cons)`.
fn options_from_form(slots: &[(&str, &str, &str)]) -> Vec<DecisionOption> {
    let mut options = Vec::with_capacity(slots.len());
    for (i, (label, pros, cons)) in slots.iter().enumerate() {
        if !label.trim().is_empty() {
            options.push(DecisionOption {
                id: format!("o{}", i + 1),
                label: label.trim().to_string(),
                pros: pros.trim().to_string(),
                cons: cons.trim().to_string(),
            });
        }
    }
    options
}

/// Parse a decision's goal select value ("" → None).
fn parse_goal_id(s: &str) -> Option<Uuid> {
    if s.is_empty() {
        None
    } else {
        Uuid::parse_str(s).ok()
    }
}

#[derive(Deserialize)]
pub(crate) struct DecisionForm {
    pub csrf_token: Option<String>,
    title: String,
    context: String,
    goal_id: String,
    opt_1_label: String,
    opt_1_pros: String,
    opt_1_cons: String,
    opt_2_label: String,
    opt_2_pros: String,
    opt_2_cons: String,
    opt_3_label: String,
    opt_3_pros: String,
    opt_3_cons: String,
}

impl DecisionForm {
    fn options(&self) -> Vec<DecisionOption> {
        options_from_form(&[
            (&self.opt_1_label, &self.opt_1_pros, &self.opt_1_cons),
            (&self.opt_2_label, &self.opt_2_pros, &self.opt_2_cons),
            (&self.opt_3_label, &self.opt_3_pros, &self.opt_3_cons),
        ])
    }
}

pub(crate) async fn decision_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<DecisionForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    let options = body.options();
    if body.title.trim().is_empty() || options.is_empty() {
        return Ok(Redirect::to(&format!(
            "/projects/{project_id}/decisions?flash=invalid_decision"
        ))
        .into_response());
    }
    state
        .repo
        .create_decision(
            project_id,
            parse_goal_id(&body.goal_id),
            body.title.trim(),
            body.context.trim(),
            &options,
            Some(auth_user.user.id),
        )
        .await?;
    Ok(Redirect::to(&format!(
        "/projects/{project_id}/decisions?flash=decision_created"
    ))
    .into_response())
}

pub(crate) async fn decision_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let decision_id = parse_uuid(&id)?;
    let decision = state
        .repo
        .find_decision(decision_id)
        .await?
        .ok_or_else(|| not_found("decision"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, decision.project_id).await
    {
        return Ok(redirect);
    }
    let project = state
        .repo
        .find_project(decision.project_id)
        .await?
        .ok_or_else(|| not_found("project"))?;
    let goals = state.repo.list_goals(decision.project_id).await?;
    let revisions = state.repo.list_revisions("decision", decision_id).await?;
    let goal_title = decision
        .goal_id
        .and_then(|gid| goals.iter().find(|g| g.id == gid))
        .map(|g| g.title.clone())
        .unwrap_or_default();
    let goal_options = goals
        .iter()
        .map(|g| GoalOptionView {
            id: g.id.to_string(),
            title: g.title.clone(),
            selected: decision.goal_id == Some(g.id),
        })
        .collect();
    let options = decision
        .options
        .iter()
        .map(|o| OptionView {
            id: o.id.clone(),
            label: o.label.clone(),
            pros_html: render_markdown(&o.pros),
            cons_html: render_markdown(&o.cons),
        })
        .collect();
    let view = DecisionView {
        status: decision.status.clone(),
        context_html: render_markdown(&decision.context),
        options,
        decided_label: decided_label(&decision),
        rationale_html: render_markdown(&decision.rationale),
        decided_at: decision
            .decided_at_ms
            .map(format_date_ms)
            .unwrap_or_default(),
        review_at: decision
            .review_at_ms
            .map(format_date_ms)
            .unwrap_or_default(),
        goal_title,
        opt1: edit_option(&decision.options, 0),
        opt2: edit_option(&decision.options, 1),
        opt3: edit_option(&decision.options, 2),
    };
    let created_by_name = creator_name(&state.repo, decision.created_by).await;
    page(&DecisionTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goal_options,
        decision,
        view,
        created_by_name,
        revisions: revisions
            .iter()
            .map(|r| RevisionView {
                created_at: format_date_ms(r.created_at_ms),
                html: render_markdown(&r.snapshot),
            })
            .collect(),
    })
}

pub(crate) async fn decision_update(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<DecisionForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let decision_id = parse_uuid(&id)?;
    let decision = state
        .repo
        .find_decision(decision_id)
        .await?
        .ok_or_else(|| not_found("decision"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, decision.project_id).await
    {
        return Ok(redirect);
    }
    let options = body.options();
    if body.title.trim().is_empty() || options.is_empty() {
        return Ok(
            Redirect::to(&format!("/decisions/{decision_id}?flash=invalid_decision"))
                .into_response(),
        );
    }
    state
        .repo
        .update_decision(
            decision_id,
            body.title.trim(),
            body.context.trim(),
            &options,
        )
        .await?;
    Ok(Redirect::to(&format!("/decisions/{decision_id}?flash=decision_updated")).into_response())
}

#[derive(Deserialize)]
pub(crate) struct ResolveForm {
    pub csrf_token: Option<String>,
    status: String,
    decided_option: String,
    rationale: String,
    review_at: String,
}

pub(crate) async fn decision_resolve(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<ResolveForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let decision_id = parse_uuid(&id)?;
    let decision = state
        .repo
        .find_decision(decision_id)
        .await?
        .ok_or_else(|| not_found("decision"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, decision.project_id).await
    {
        return Ok(redirect);
    }
    let requested = body.status.as_str();
    let decided_option = if requested == "decided" && !body.decided_option.is_empty() {
        Some(body.decided_option.clone())
    } else {
        None
    };
    // A decision cannot be "decided" without a chosen option; fall back to open.
    let status = if decided_option.is_some() {
        if matches!(requested, "decided" | "rejected") {
            requested
        } else {
            "open"
        }
    } else if matches!(requested, "open" | "rejected") {
        requested
    } else {
        "open"
    };
    let review_at = parse_date_ms(body.review_at.trim());
    state
        .repo
        .resolve_decision(
            decision_id,
            status,
            decided_option,
            body.rationale.trim(),
            review_at,
        )
        .await?;
    Ok(Redirect::to(&format!("/decisions/{decision_id}?flash=decision_resolved")).into_response())
}

pub(crate) async fn decision_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let decision_id = parse_uuid(&id)?;
    let project_id = state
        .repo
        .find_decision(decision_id)
        .await?
        .ok_or_else(|| not_found("decision"))?
        .project_id;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_decision(decision_id).await?;
    Ok(Redirect::to(&format!(
        "/projects/{project_id}/decisions?flash=decision_deleted"
    ))
    .into_response())
}

// ---------------------------------------------------------------------------
// Experiments & events
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct ExperimentForm {
    pub csrf_token: Option<String>,
    title: String,
    hypothesis: String,
    goal_id: String,
    decision_id: String,
}

pub(crate) async fn experiment_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<ExperimentForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if body.title.trim().is_empty() {
        return Ok(Redirect::to(&format!(
            "/projects/{project_id}/experiments?flash=invalid_title"
        ))
        .into_response());
    }
    let goal_id = parse_goal_id(&body.goal_id);
    let decision_id = parse_goal_id(&body.decision_id);
    state
        .repo
        .create_experiment(
            project_id,
            goal_id,
            decision_id,
            body.title.trim(),
            body.hypothesis.trim(),
            Some(auth_user.user.id),
        )
        .await?;
    Ok(Redirect::to(&format!(
        "/projects/{project_id}/experiments?flash=experiment_created"
    ))
    .into_response())
}

pub(crate) async fn experiment_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let experiment_id = parse_uuid(&id)?;
    let experiment = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, experiment.project_id).await
    {
        return Ok(redirect);
    }
    let project = state
        .repo
        .find_project(experiment.project_id)
        .await?
        .ok_or_else(|| not_found("project"))?;
    let goal_title = match experiment.goal_id {
        Some(goal_id) => state
            .repo
            .find_goal(goal_id)
            .await?
            .map(|g| g.title)
            .unwrap_or_default(),
        None => String::new(),
    };
    let decision_title = match experiment.decision_id {
        Some(decision_id) => state
            .repo
            .find_decision(decision_id)
            .await?
            .map(|d| d.title)
            .unwrap_or_default(),
        None => String::new(),
    };
    let events = state.repo.list_events(experiment.id).await?;
    let view = ExperimentView {
        started_at: experiment
            .started_at_ms
            .map(format_date_ms)
            .unwrap_or_default(),
        ended_at: experiment
            .ended_at_ms
            .map(format_date_ms)
            .unwrap_or_default(),
        hypothesis_html: render_markdown(&experiment.hypothesis),
        result_html: render_markdown(&experiment.result),
        lesson_html: render_markdown(&experiment.lesson),
        goal_title,
        decision_title,
    };
    let events_view: Vec<EventView> = events
        .into_iter()
        .map(|ev| EventView {
            id: ev.id.to_string(),
            kind: ev.kind,
            at: format_date_ms(ev.at_ms),
            note_html: render_markdown(&ev.note),
        })
        .collect();
    let created_by_name = creator_name(&state.repo, experiment.created_by).await;
    page(&ExperimentTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        experiment,
        view,
        created_by_name,
        events: events_view,
    })
}

#[derive(Deserialize)]
pub(crate) struct ExperimentUpdateForm {
    pub csrf_token: Option<String>,
    title: String,
    hypothesis: String,
    status: String,
    result: String,
    lesson: String,
}

pub(crate) async fn experiment_update(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<ExperimentUpdateForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let experiment_id = parse_uuid(&id)?;
    let experiment = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, experiment.project_id).await
    {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/experiments/{experiment_id}?flash=invalid_title"))
                .into_response(),
        );
    }
    let status = if matches!(
        body.status.as_str(),
        "planned" | "ongoing" | "done" | "abandoned"
    ) {
        body.status.as_str()
    } else {
        "planned"
    };
    state
        .repo
        .update_experiment(
            experiment_id,
            body.title.trim(),
            body.hypothesis.trim(),
            status,
            body.result.trim(),
            body.lesson.trim(),
        )
        .await?;
    Ok(Redirect::to(&format!(
        "/experiments/{experiment_id}?flash=experiment_updated"
    ))
    .into_response())
}

pub(crate) async fn experiment_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let experiment_id = parse_uuid(&id)?;
    let project_id = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?
        .project_id;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_experiment(experiment_id).await?;
    Ok(Redirect::to(&format!(
        "/projects/{project_id}/experiments?flash=experiment_deleted"
    ))
    .into_response())
}

#[derive(Deserialize)]
pub(crate) struct EventForm {
    pub csrf_token: Option<String>,
    kind: String,
    at_date: String,
    note: String,
}

pub(crate) async fn event_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<EventForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let experiment_id = parse_uuid(&id)?;
    let experiment = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, experiment.project_id).await
    {
        return Ok(redirect);
    }
    let kind = if matches!(
        body.kind.as_str(),
        "observation" | "measurement" | "milestone"
    ) {
        body.kind.as_str()
    } else {
        "observation"
    };
    if body.note.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/experiments/{experiment_id}?flash=invalid_event"))
                .into_response(),
        );
    }
    let at_ms = parse_date_ms(body.at_date.trim()).unwrap_or_else(now_ms);
    state
        .repo
        .create_event(experiment_id, kind, at_ms, body.note.trim())
        .await?;
    Ok(Redirect::to(&format!("/experiments/{experiment_id}?flash=event_created")).into_response())
}

pub(crate) async fn event_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((id, event_id)): Path<(String, String)>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let experiment_id = parse_uuid(&id)?;
    let event_id = parse_uuid(&event_id)?;
    let experiment = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, experiment.project_id).await
    {
        return Ok(redirect);
    }
    state.repo.delete_event(event_id).await?;
    Ok(Redirect::to(&format!("/experiments/{experiment_id}?flash=event_deleted")).into_response())
}

pub(crate) async fn timeline_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let project_id = project.id;
    let entries = state.repo.timeline(project_id).await?;
    let entries_view = entries
        .into_iter()
        .map(|e: TimelineEntry| TimelineView {
            at: format_date_ms(e.at_ms),
            kind: e.kind,
            note: e.note,
            experiment_id: e.experiment_id.to_string(),
        })
        .collect();
    page(&TimelineTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        entries: entries_view,
    })
}

// ---------------------------------------------------------------------------
// Knowledge: notes, links, graph
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct NoteForm {
    pub csrf_token: Option<String>,
    title: String,
    body: String,
}

pub(crate) async fn note_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<NoteForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/notes?flash=invalid_title"))
                .into_response(),
        );
    }
    let note = state
        .repo
        .create_note(
            project_id,
            body.title.trim(),
            body.body.trim(),
            None,
            None,
            Some(auth_user.user.id),
        )
        .await?;
    Ok(Redirect::to(&format!("/notes/{}?flash=note_created", note.id)).into_response())
}

pub(crate) async fn note_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let note_id = parse_uuid(&id)?;
    let note = state
        .repo
        .find_note(note_id)
        .await?
        .ok_or_else(|| not_found("note"))?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, note.project_id).await {
        return Ok(redirect);
    }
    let project = state
        .repo
        .find_project(note.project_id)
        .await?
        .ok_or_else(|| not_found("project"))?;
    let (source_title, source_url) = match (&note.source_type, note.source_id) {
        (Some(st), Some(si)) if st == "experiment" => {
            let title = state
                .repo
                .find_experiment(si)
                .await?
                .map(|e| e.title)
                .unwrap_or_default();
            (title, format!("/experiments/{si}"))
        }
        (Some(st), Some(si)) if st == "decision" => {
            let title = state
                .repo
                .find_decision(si)
                .await?
                .map(|d| d.title)
                .unwrap_or_default();
            (title, format!("/decisions/{si}"))
        }
        _ => (String::new(), String::new()),
    };
    let revisions = state.repo.list_revisions("note", note.id).await?;
    let view = NoteView {
        body_html: render_markdown(&note.body),
        source_title,
        source_url,
    };
    let revisions_view: Vec<RevisionView> = revisions
        .into_iter()
        .map(|r| RevisionView {
            created_at: format_date_ms(r.created_at_ms),
            html: render_markdown(&r.snapshot),
        })
        .collect();
    let created_by_name = creator_name(&state.repo, note.created_by).await;
    page(&NoteTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        note,
        view,
        created_by_name,
        revisions: revisions_view,
    })
}

pub(crate) async fn note_update(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<NoteForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let note_id = parse_uuid(&id)?;
    let note = state
        .repo
        .find_note(note_id)
        .await?
        .ok_or_else(|| not_found("note"))?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, note.project_id).await {
        return Ok(redirect);
    }
    if body.title.trim().is_empty() {
        return Ok(Redirect::to(&format!("/notes/{note_id}?flash=invalid_title")).into_response());
    }
    state
        .repo
        .update_note(note_id, body.title.trim(), body.body.trim())
        .await?;
    Ok(Redirect::to(&format!("/notes/{note_id}?flash=note_updated")).into_response())
}

pub(crate) async fn note_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let note_id = parse_uuid(&id)?;
    let project_id = state
        .repo
        .find_note(note_id)
        .await?
        .ok_or_else(|| not_found("note"))?
        .project_id;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_note(note_id).await?;
    Ok(Redirect::to(&format!("/projects/{project_id}/notes?flash=note_deleted")).into_response())
}

/// Capture an experiment's lesson as a knowledge note, keeping the source
/// pointer so the graph can trace where the knowledge came from.
pub(crate) async fn note_extract(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let experiment_id = parse_uuid(&id)?;
    let experiment = state
        .repo
        .find_experiment(experiment_id)
        .await?
        .ok_or_else(|| not_found("experiment"))?;
    if let Err(redirect) =
        require_member_or_admin(&state, &auth_user.user, experiment.project_id).await
    {
        return Ok(redirect);
    }
    let body_text = if experiment.lesson.trim().is_empty() {
        experiment.result.trim().to_string()
    } else {
        experiment.lesson.trim().to_string()
    };
    if body_text.is_empty() {
        return Ok(
            Redirect::to(&format!("/experiments/{experiment_id}?flash=no_lesson")).into_response(),
        );
    }
    let note = state
        .repo
        .create_note(
            experiment.project_id,
            &format!("Lesson: {}", experiment.title),
            &body_text,
            Some("experiment"),
            Some(experiment.id),
            Some(auth_user.user.id),
        )
        .await?;
    Ok(Redirect::to(&format!("/notes/{}?flash=note_extracted", note.id)).into_response())
}

#[derive(Deserialize)]
pub(crate) struct LinkForm {
    pub csrf_token: Option<String>,
    /// Combined `type:uuid` values from the selects.
    from: String,
    to: String,
    kind: String,
}

pub(crate) async fn link_create(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<LinkForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    let Some((from_type, from_id)) = split_entity(&body.from) else {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/graph?flash=invalid_link"))
                .into_response(),
        );
    };
    let Some((to_type, to_id)) = split_entity(&body.to) else {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/graph?flash=invalid_link"))
                .into_response(),
        );
    };
    let kind = if matches!(
        body.kind.as_str(),
        "related" | "supports" | "rejects" | "follows"
    ) {
        body.kind.clone()
    } else {
        "related".into()
    };
    if from_id == to_id && from_type == to_type {
        return Ok(
            Redirect::to(&format!("/projects/{project_id}/graph?flash=invalid_link"))
                .into_response(),
        );
    }
    state
        .repo
        .create_link(project_id, &from_type, from_id, &to_type, to_id, &kind)
        .await?;
    Ok(Redirect::to(&format!("/projects/{project_id}/graph?flash=link_created")).into_response())
}

/// Parse a `type:uuid` select value.
fn split_entity(value: &str) -> Option<(String, Uuid)> {
    let (t, id) = value.split_once(':')?;
    if !matches!(t, "note" | "decision" | "experiment") {
        return None;
    }
    let id = Uuid::from_str(id).ok()?;
    Some((t.to_string(), id))
}

pub(crate) async fn link_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((id, link_id)): Path<(String, String)>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let project_id = parse_uuid(&id)?;
    let link_id = parse_uuid(&link_id)?;
    if let Err(redirect) = require_member_or_admin(&state, &auth_user.user, project_id).await {
        return Ok(redirect);
    }
    state.repo.delete_link(link_id).await?;
    Ok(Redirect::to(&format!("/projects/{project_id}/graph?flash=link_deleted")).into_response())
}

pub(crate) async fn graph_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;
    let project_id = project.id;
    let data: GraphData = state.repo.graph(project_id).await?;
    let mut titles: HashMap<(String, Uuid), String> = HashMap::new();
    let mut nodes = Vec::with_capacity(data.nodes.len());
    for n in &data.nodes {
        titles.insert((n.node_type.clone(), n.id), n.title.clone());
        nodes.push(GraphNodeView {
            node_type: n.node_type.clone(),
            title: n.title.clone(),
            url: match n.node_type.as_str() {
                "goal" => format!("/goals/{}", n.id),
                "decision" => format!("/decisions/{}", n.id),
                "experiment" => format!("/experiments/{}", n.id),
                _ => format!("/notes/{}", n.id),
            },
        });
    }
    let explicit_kinds = ["related", "supports", "rejects", "follows"];
    let mut implicit = Vec::new();
    for e in &data.edges {
        if explicit_kinds.contains(&e.kind.as_str()) {
            continue;
        }
        implicit.push(GraphEdgeView {
            from_label: label_for(&titles, &e.from_type, e.from_id, &e.from_type),
            to_label: label_for(&titles, &e.to_type, e.to_id, &e.to_type),
            kind: e.kind.clone(),
        });
    }
    let links = state.repo.list_links(project_id).await?;
    let links_view = links
        .into_iter()
        .map(|l| LinkView {
            id: l.id.to_string(),
            from_label: label_for(&titles, &l.from_type, l.from_id, &l.from_type),
            to_label: label_for(&titles, &l.to_type, l.to_id, &l.to_type),
            kind: l.kind,
        })
        .collect();
    let link_entities: Vec<EntityChoiceView> = titles
        .iter()
        .filter(|((t, _), _)| t != "goal")
        .map(|((t, id), title)| EntityChoiceView {
            type_name: t.clone(),
            id: id.to_string(),
            label: title.clone(),
        })
        .collect();
    page(&GraphTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        nodes,
        implicit,
        links: links_view,
        link_entities,
    })
}

/// Human label for a graph edge endpoint, falling back to the raw type.
fn label_for(
    titles: &HashMap<(String, Uuid), String>,
    node_type: &str,
    id: Uuid,
    fallback: &str,
) -> String {
    titles
        .get(&(node_type.to_string(), id))
        .cloned()
        .unwrap_or_else(|| format!("{fallback}…"))
}

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
pub(crate) struct SearchQuery {
    q: Option<String>,
}

pub(crate) async fn search_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(query): Query<SearchQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let raw = query.q.unwrap_or_default();
    let project_ids = if auth::is_admin(&auth_user.user) {
        None
    } else {
        let projects = state
            .repo
            .list_projects_for_user(auth_user.user.id)
            .await?;
        let ids: Vec<Uuid> = projects.iter().map(|p| p.id).collect();
        Some(ids)
    };
    let results: Vec<SearchRow> = state
        .repo
        .search(&raw, project_ids.as_deref())
        .await?;
    let results_view = results
        .into_iter()
        .map(|r| {
            let url = match r.entity_type.as_str() {
                "goal" => format!("/goals/{}", r.entity_id),
                "decision" => format!("/decisions/{}", r.entity_id),
                "experiment" => format!("/experiments/{}", r.entity_id),
                "note" => format!("/notes/{}", r.entity_id),
                "project" => format!("/projects/{}", r.entity_id),
                _ => format!("/projects/{}", r.project_id),
            };
            SearchItemView {
                url,
                title: r.title,
                entity_type: r.entity_type,
                project_title: r.project_title,
                snippet_html: highlight_snippet(&r.snippet),
            }
        })
        .collect();
    page(&SearchTemplate {
        authed: true,
        flash: String::new(),
        flash_kind: "notice--info",
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        query: raw,
        results: results_view,
    })
}

/// HTML-escape a string for safe inline display.
fn escape_html(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

/// Take a raw FTS snippet whose matches are wrapped in control chars
/// (char(1)/char(2) from the SQL `snippet()` call), escape it, then convert
/// the markers into `<mark>` tags. Safe to emit with `|safe`.
fn highlight_snippet(raw: &str) -> String {
    escape_html(raw)
        .replace('\u{1}', "<mark>")
        .replace('\u{2}', "</mark>")
}

// ---------------------------------------------------------------------------
// Admin: user management
// ---------------------------------------------------------------------------

pub(crate) async fn admin_users_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Ok(Redirect::to("/dashboard?flash=access_denied").into_response());
    }
    let users = state.repo.list_users().await?;
    let all_projects = state.repo.list_projects().await?;
    let mut pending_with_projects = Vec::new();
    let mut approved_with_projects = Vec::new();
    for user in users {
        let projects = state.repo.list_projects_for_user(user.id).await?;
        let entry = UserWithProjects { user, projects };
        if entry.user.approved {
            approved_with_projects.push(entry);
        } else {
            pending_with_projects.push(entry);
        }
    }
    page(&AdminUsersTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        pending_with_projects,
        approved_with_projects,
        all_projects,
    })
}

pub(crate) async fn admin_user_approve(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    state.repo.approve_user(user_id).await?;
    Ok(Redirect::to("/admin/users?flash=approved").into_response())
}

pub(crate) async fn admin_user_reject(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    state.repo.reject_user(user_id).await?;
    Ok(Redirect::to("/admin/users?flash=rejected").into_response())
}

pub(crate) async fn admin_user_role(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    let user = state
        .repo
        .find_user_by_id(user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("user not found"))?;
    let new_role = if user.role == "admin" {
        // Prevent demoting the last admin.
        if state.repo.count_admins().await? <= 1 {
            return Ok(Redirect::to("/admin/users?flash=cannot_demote_last_admin").into_response());
        }
        "user"
    } else {
        "admin"
    };
    state.repo.set_user_role(user_id, new_role).await?;
    Ok(Redirect::to("/admin/users?flash=role_updated").into_response())
}

pub(crate) async fn admin_user_delete(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    // Don't let admin delete themselves.
    if user_id == auth_user.user.id {
        return Ok(Redirect::to("/admin/users?flash=cannot_delete_self").into_response());
    }
    // Prevent deleting the last admin.
    let target = state
        .repo
        .find_user_by_id(user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("user not found"))?;
    if target.role == "admin" && state.repo.count_admins().await? <= 1 {
        return Ok(Redirect::to("/admin/users?flash=cannot_delete_last_admin").into_response());
    }
    state.repo.delete_user(user_id).await?;
    Ok(Redirect::to("/admin/users?flash=deleted").into_response())
}

#[derive(Deserialize)]
pub(crate) struct AdminProjectForm {
    pub csrf_token: Option<String>,
    pub project_id: String,
}

pub(crate) async fn admin_user_add_to_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<AdminProjectForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    let project_id = parse_uuid(&body.project_id)?;
    state
        .repo
        .add_project_member(project_id, user_id, "member")
        .await?;
    Ok(Redirect::to("/admin/users?flash=member_added").into_response())
}

pub(crate) async fn admin_user_remove_from_project(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<AdminProjectForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let user_id = parse_uuid(&id)?;
    let project_id = parse_uuid(&body.project_id)?;
    state
        .repo
        .remove_project_member(project_id, user_id)
        .await?;
    Ok(Redirect::to("/admin/users?flash=member_removed").into_response())
}

// ---------------------------------------------------------------------------
// Admin: settings (placeholder for future system config)
// ---------------------------------------------------------------------------

pub(crate) async fn admin_settings_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    page(&AdminSettingsTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
    })
}

pub(crate) async fn admin_settings_form(
    State(state): State<AppState>,
    headers: HeaderMap,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_admin(&auth_user.user) {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    // Placeholder: no settings to save yet.
    Ok(Redirect::to("/admin/settings?flash=updated").into_response())
}

// ---------------------------------------------------------------------------
// Project members
// ---------------------------------------------------------------------------

pub(crate) async fn project_members_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    let project_id = parse_uuid(&id)?;
    // Must be admin or project member.
    if !auth::is_admin(&auth_user.user)
        && !state
            .repo
            .is_project_member(auth_user.user.id, project_id)
            .await?
    {
        return Err(ApiError::forbidden().into());
    }
    let project = state
        .repo
        .find_project(project_id)
        .await?
        .ok_or_else(|| ApiError::not_found("project not found"))?;
    let members = state.repo.list_project_members(project_id).await?;
    let all_users = state.repo.list_users().await?;
    let is_owner = auth::is_admin(&auth_user.user)
        || state
            .repo
            .user_project_role(auth_user.user.id, project_id)
            .await?
            == Some("owner".to_string());
    page(&ProjectMembersTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        members,
        all_users,
        is_owner,
    })
}

#[derive(Deserialize)]
pub(crate) struct MemberForm {
    pub csrf_token: Option<String>,
    pub user_id: String,
}

pub(crate) async fn project_member_add(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Form(body): Form<MemberForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    let project_id = parse_uuid(&id)?;
    // Must be admin or project owner.
    if !auth::is_admin(&auth_user.user)
        && state
            .repo
            .user_project_role(auth_user.user.id, project_id)
            .await?
            != Some("owner".to_string())
    {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    let member_id = parse_uuid(&body.user_id)?;
    state
        .repo
        .add_project_member(project_id, member_id, "member")
        .await?;
    Ok(Redirect::to(&format!(
        "/projects/{}/members?flash=member_added",
        project_id
    ))
    .into_response())
}

pub(crate) async fn project_member_remove(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path((id, uid)): Path<(String, String)>,
    Form(body): Form<CsrfForm>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    if !auth::is_approved(&auth_user.user) {
        return Ok(Redirect::to("/login?flash=not_approved").into_response());
    }
    let project_id = parse_uuid(&id)?;
    let member_id = parse_uuid(&uid)?;
    // Must be admin or project owner.
    if !auth::is_admin(&auth_user.user)
        && state
            .repo
            .user_project_role(auth_user.user.id, project_id)
            .await?
            != Some("owner".to_string())
    {
        return Err(ApiError::forbidden().into());
    }
    auth::verify_csrf_form(&headers, body.csrf_token.as_deref(), &auth_user.csrf_token)?;
    // Don't let the last owner remove themselves.
    let role = state.repo.user_project_role(member_id, project_id).await?;
    if role == Some("owner".to_string()) {
        let members = state.repo.list_project_members(project_id).await?;
        let owner_count = members.iter().filter(|(_, r)| r == "owner").count();
        if owner_count <= 1 {
            return Ok(Redirect::to(&format!(
                "/projects/{}/members?flash=cannot_remove_last_owner",
                project_id
            ))
            .into_response());
        }
    }
    state
        .repo
        .remove_project_member(project_id, member_id)
        .await?;
    Ok(Redirect::to(&format!(
        "/projects/{}/members?flash=member_removed",
        project_id
    ))
    .into_response())
}

// ---------------------------------------------------------------------------
// Kanban board
// ---------------------------------------------------------------------------

pub(crate) async fn board_page(
    State(state): State<AppState>,
    headers: HeaderMap,
    Path(id): Path<String>,
    Query(flash): Query<FlashQuery>,
) -> Result<Response, PageError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Ok(login_redirect());
    };
    let project = require_project_member(&state, &id, &auth_user.user).await?;

    let goals_raw = state.repo.list_goals(project.id).await?;
    let decisions_raw = state.repo.list_decisions(project.id).await?;
    let experiments_raw = state.repo.list_experiments(project.id).await?;

    let mut goals_open = Vec::new();
    let mut goals_ongoing = Vec::new();
    let mut goals_done = Vec::new();
    let mut goals_dropped = Vec::new();
    for g in goals_raw {
        let assigned_to_name = creator_name(&state.repo, g.assigned_to).await;
        let view = GoalItemView {
            id: g.id.to_string(),
            title: g.title,
            status: g.status.clone(),
            body_html: render_markdown(&g.body),
            assigned_to_name,
        };
        match g.status.as_str() {
            "ongoing" => goals_ongoing.push(view),
            "done" => goals_done.push(view),
            "dropped" => goals_dropped.push(view),
            _ => goals_open.push(view),
        }
    }

    let mut decisions_open = Vec::new();
    let mut decisions_decided = Vec::new();
    let mut decisions_rejected = Vec::new();
    for d in decisions_raw {
        let decided_label = decided_label(&d);
        let view = DecisionItemView {
            id: d.id.to_string(),
            title: d.title,
            status: d.status.clone(),
            decided_label,
        };
        match d.status.as_str() {
            "decided" => decisions_decided.push(view),
            "rejected" => decisions_rejected.push(view),
            _ => decisions_open.push(view),
        }
    }

    let mut experiments_planned = Vec::new();
    let mut experiments_ongoing = Vec::new();
    let mut experiments_done = Vec::new();
    let mut experiments_abandoned = Vec::new();
    for e in experiments_raw {
        let view = ExperimentItemView {
            id: e.id.to_string(),
            title: e.title,
            status: e.status.clone(),
        };
        match e.status.as_str() {
            "ongoing" => experiments_ongoing.push(view),
            "done" => experiments_done.push(view),
            "abandoned" => experiments_abandoned.push(view),
            _ => experiments_planned.push(view),
        }
    }

    page(&BoardTemplate {
        authed: true,
        flash: flash_view(flash.flash.as_deref()).0,
        flash_kind: flash_view(flash.flash.as_deref()).1,
        year: current_year(),
        display_name: auth_user.user.display_name,
        csrf_token: auth_user.csrf_token,
        project,
        goals_open,
        goals_ongoing,
        goals_done,
        goals_dropped,
        decisions_open,
        decisions_decided,
        decisions_rejected,
        experiments_planned,
        experiments_ongoing,
        experiments_done,
        experiments_abandoned,
    })
}

#[derive(serde::Deserialize)]
pub(crate) struct StatusChangeRequest {
    entity: String,
    id: String,
    status: String,
}

pub(crate) async fn api_status_change(
    State(state): State<AppState>,
    headers: HeaderMap,
    axum::extract::Json(body): axum::extract::Json<StatusChangeRequest>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let Some(auth_user) = auth::session_user(&state, &headers).await else {
        return Err(ApiError::forbidden());
    };
    if !auth::is_approved(&auth_user.user) {
        return Err(ApiError::forbidden());
    }

    let entity_id = Uuid::parse_str(&body.id).map_err(|_| {
        ApiError::bad_request("invalid entity id")
    })?;

    match body.entity.as_str() {
        "goal" => {
            if !matches!(body.status.as_str(), "open" | "ongoing" | "done" | "dropped") {
                return Err(ApiError::bad_request("invalid goal status"));
            }
            let goal = state
                .repo
                .find_goal(entity_id)
                .await?
                .ok_or_else(|| ApiError::not_found("goal"))?;
            require_member_or_admin(&state, &auth_user.user, goal.project_id)
                .await
                .map_err(|_| ApiError::forbidden())?;
            state.repo.update_goal_status(entity_id, &body.status).await?;
        }
        "decision" => {
            if !matches!(body.status.as_str(), "open" | "decided" | "rejected") {
                return Err(ApiError::bad_request("invalid decision status"));
            }
            let decision = state
                .repo
                .find_decision(entity_id)
                .await?
                .ok_or_else(|| ApiError::not_found("decision"))?;
            require_member_or_admin(&state, &auth_user.user, decision.project_id)
                .await
                .map_err(|_| ApiError::forbidden())?;
            state
                .repo
                .update_decision_status(entity_id, &body.status)
                .await?;
        }
        "experiment" => {
            if !matches!(body.status.as_str(), "planned" | "ongoing" | "done" | "abandoned") {
                return Err(ApiError::bad_request("invalid experiment status"));
            }
            let experiment = state
                .repo
                .find_experiment(entity_id)
                .await?
                .ok_or_else(|| ApiError::not_found("experiment"))?;
            require_member_or_admin(&state, &auth_user.user, experiment.project_id)
                .await
                .map_err(|_| ApiError::forbidden())?;
            state
                .repo
                .update_experiment_status(entity_id, &body.status)
                .await?;
        }
        _ => {
            return Err(ApiError::bad_request("invalid entity type"));
        }
    }

    Ok(Json(serde_json::json!({ "ok": true })))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn uuid() -> Uuid {
        Uuid::new_v4()
    }

    // -- options_from_form -------------------------------------------------

    #[test]
    fn options_from_form_trims_and_drops_blanks() {
        let out = options_from_form(&[
            ("  PostgreSQL  ", " easy ", " heavy "),
            ("   ", "ignored", "ignored"),
            ("SQLite", "one binary", ""),
            ("", "ignored", "ignored"),
        ]);
        assert_eq!(out.len(), 2);
        assert_eq!(out[0].id, "o1");
        assert_eq!(out[0].label, "PostgreSQL");
        assert_eq!(out[0].pros, "easy");
        assert_eq!(out[0].cons, "heavy");
        assert_eq!(
            out[1].id, "o3",
            "ids follow the form slot, not the kept count"
        );
        assert_eq!(out[1].label, "SQLite");
        assert_eq!(out[1].cons, "");
    }

    #[test]
    fn options_from_form_empty() {
        assert!(options_from_form(&[]).is_empty());
        assert!(options_from_form(&[("", "", "")]).is_empty());
    }

    // -- split_entity ------------------------------------------------------

    #[test]
    fn split_entity_parses_valid_values() {
        let id = uuid();
        for t in ["note", "decision", "experiment"] {
            let (kind, parsed) = split_entity(&format!("{t}:{id}")).unwrap();
            assert_eq!(kind, t);
            assert_eq!(parsed, id);
        }
    }

    #[test]
    fn split_entity_rejects_bad_values() {
        let id = uuid();
        assert!(split_entity("").is_none());
        assert!(split_entity(":foo").is_none());
        assert!(
            split_entity(&format!("goal:{id}")).is_none(),
            "goals aren't linkable"
        );
        assert!(split_entity("note:not-a-uuid").is_none());
        assert!(split_entity(&format!("note:{id}:extra")).is_none());
    }

    // -- escape_html / highlight_snippet -----------------------------------

    #[test]
    fn escape_html_escapes_special_chars() {
        assert_eq!(
            escape_html(r#"<a href="x"> & </a>"#),
            "&lt;a href=&quot;x&quot;&gt; &amp; &lt;/a&gt;"
        );
    }

    #[test]
    fn highlight_snippet_escapes_then_marks() {
        let raw = "a \u{1}<b>\u{2} & c";
        let out = highlight_snippet(raw);
        assert_eq!(out, "a <mark>&lt;b&gt;</mark> &amp; c");
        assert!(!out.contains('\u{1}') && !out.contains('\u{2}'));
    }

    #[test]
    fn highlight_snippet_without_marks_is_plain() {
        assert_eq!(
            highlight_snippet("just text & more"),
            "just text &amp; more"
        );
    }

    // -- decided_label -----------------------------------------------------

    #[test]
    fn decided_label_finds_chosen_option() {
        let mut d = Decision {
            id: uuid(),
            project_id: uuid(),
            goal_id: None,
            title: "t".into(),
            context: String::new(),
            options: vec![
                DecisionOption {
                    id: "o1".into(),
                    label: "One".into(),
                    pros: String::new(),
                    cons: String::new(),
                },
                DecisionOption {
                    id: "o2".into(),
                    label: "Two".into(),
                    pros: String::new(),
                    cons: String::new(),
                },
            ],
            status: "decided".into(),
            decided_option: Some("o2".into()),
            rationale: String::new(),
            decided_at_ms: None,
            review_at_ms: None,
            created_by: None,
            created_at_ms: 0,
            updated_at_ms: 0,
        };
        assert_eq!(decided_label(&d), "Two");
        d.decided_option = Some("missing".into());
        assert_eq!(decided_label(&d), "", "unknown id → empty");
        d.decided_option = None;
        assert_eq!(decided_label(&d), "", "unresolved → empty");
    }

    // -- parse_goal_id -----------------------------------------------------

    #[test]
    fn parse_goal_id_empty_is_none() {
        assert_eq!(parse_goal_id(""), None);
    }

    #[test]
    fn parse_goal_id_valid_uuid() {
        let id = uuid();
        assert_eq!(parse_goal_id(&id.to_string()), Some(id));
    }

    #[test]
    fn parse_goal_id_invalid_is_none() {
        assert_eq!(parse_goal_id("not-a-uuid"), None);
    }

    // -- validate_setup ----------------------------------------------------

    fn setup_form(username: &str, display: &str, password: &str, confirm: &str) -> SetupForm {
        SetupForm {
            username: username.into(),
            display: display.into(),
            password: password.into(),
            confirm: confirm.into(),
        }
    }

    #[test]
    fn validate_setup_accepts_valid() {
        assert_eq!(
            validate_setup(&setup_form("dev", "Dev", "longenough1", "longenough1")),
            ""
        );
        assert_eq!(
            validate_setup(&setup_form("dev_2-x", "D", "longenough1", "longenough1")),
            ""
        );
    }

    #[test]
    fn validate_setup_rejects_bad_username() {
        let base = |u: &str| setup_form(u, "Dev", "longenough1", "longenough1");
        assert!(!validate_setup(&base("")).is_empty());
        assert!(!validate_setup(&base("Dev")).is_empty(), "uppercase");
        assert!(!validate_setup(&base("dev name")).is_empty(), "space");
        assert!(!validate_setup(&base("de")).is_empty(), "too short");
        assert!(!validate_setup(&base("dév")).is_empty(), "non-ascii");
    }

    #[test]
    fn validate_setup_rejects_password_issues() {
        assert!(!validate_setup(&setup_form("dev", "", "longenough1", "longenough1")).is_empty());
        assert!(!validate_setup(&setup_form("dev", "Dev", "short1", "short1")).is_empty());
        assert!(
            !validate_setup(&setup_form("dev", "Dev", "longenough1", "longenough2")).is_empty()
        );
    }

    // -- validate_register --------------------------------------------------

    fn register_form(username: &str, display: &str, password: &str, confirm: &str) -> RegisterForm {
        RegisterForm {
            username: username.into(),
            display: display.into(),
            password: password.into(),
            confirm: confirm.into(),
        }
    }

    #[test]
    fn validate_register_accepts_valid() {
        assert_eq!(
            validate_register(&register_form(
                "alice",
                "Alice",
                "longenough1",
                "longenough1"
            )),
            ""
        );
        assert_eq!(
            validate_register(&register_form("bob_2-x", "B", "longenough1", "longenough1")),
            ""
        );
    }

    #[test]
    fn validate_register_rejects_bad_username() {
        let base = |u: &str| register_form(u, "Alice", "longenough1", "longenough1");
        assert!(!validate_register(&base("")).is_empty());
        assert!(!validate_register(&base("Alice")).is_empty(), "uppercase");
        assert!(!validate_register(&base("alice bob")).is_empty(), "space");
        assert!(!validate_register(&base("al")).is_empty(), "too short");
        assert!(!validate_register(&base("aliév")).is_empty(), "non-ascii");
    }

    #[test]
    fn validate_register_rejects_password_issues() {
        assert!(
            !validate_register(&register_form("alice", "", "longenough1", "longenough1"))
                .is_empty()
        );
        assert!(
            !validate_register(&register_form("alice", "Alice", "short1", "short1")).is_empty()
        );
        assert!(
            !validate_register(&register_form(
                "alice",
                "Alice",
                "longenough1",
                "longenough2"
            ))
            .is_empty()
        );
    }

    // -- edit_option -------------------------------------------------------

    #[test]
    fn edit_option_pads_missing_slots() {
        let opt = edit_option(&[], 0);
        assert_eq!(opt.label, "");
        let with = DecisionOption {
            id: "o1".into(),
            label: "A".into(),
            pros: "p".into(),
            cons: "c".into(),
        };
        let opt = edit_option(&[with], 0);
        assert_eq!(opt.label, "A");
        assert_eq!(opt.pros, "p");
    }
}
