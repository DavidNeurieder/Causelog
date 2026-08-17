//! Integration tests against the server-rendered app. Uses an in-memory
//! SQLite database per test via `tower::ServiceExt::oneshot`.

use axum::body::Body;
use axum::http::{Request, StatusCode, header};
use http_body_util::BodyExt;
use causelog_server::app;
use causelog_server::repository::{Repository, SqliteRepository};
use std::sync::Arc;
use tower::ServiceExt;
use uuid::Uuid;

/// Build the router with a fresh in-memory database, migrated.
async fn test_app() -> axum::Router {
    let (router, _repo) = test_app_with_repo().await;
    router
}

/// Build the router with a fresh in-memory database, migrated.
/// Returns both the router and the repository handle for direct DB access.
async fn test_app_with_repo() -> (axum::Router, Arc<dyn Repository>) {
    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    let repo = repo_box(repo);
    (app(repo.clone()), repo)
}

/// Create a project via POST /projects and return the redirect URL.
async fn create_project(router: &axum::Router, cookie: &str, title: &str, status: &str) -> String {
    let csrf = csrf_from_page(router, cookie).await;
    let res = send(
        router,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", title),
                    ("summary", ""),
                    ("status", status),
                ],
            ),
            cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    redirect_to(&res)
}

/// Wrap a raw session token in the full cookie header value.
fn session_cookie(token: &str) -> String {
    format!("causelog_session={token}")
}

fn repo_box(repo: SqliteRepository) -> Arc<dyn Repository> {
    Arc::new(repo)
}

/// Send a request and return the raw response.
async fn send(router: &axum::Router, req: Request<Body>) -> axum::response::Response {
    router.clone().oneshot(req).await.unwrap()
}

async fn body_string(res: axum::response::Response) -> String {
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    String::from_utf8_lossy(&bytes).into_owned()
}

fn get(uri: &str) -> Request<Body> {
    Request::builder().uri(uri).body(Body::empty()).unwrap()
}

#[tokio::test]
async fn health_returns_ok() {
    let app = test_app().await;
    let res = send(&app, get("/health")).await;
    assert_eq!(res.status(), StatusCode::OK);
    assert_eq!(body_string(res).await, r#"{"status":"ok"}"#);
}

#[tokio::test]
async fn unknown_route_is_404() {
    let app = test_app().await;
    let res = send(&app, get("/nope")).await;
    assert_eq!(res.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn setup_is_incomplete_after_migrate() {
    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    assert!(!repo.is_setup_complete().await.unwrap());
}

#[tokio::test]
async fn setup_flag_persists() {
    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    repo.set_setup_complete(true).await.unwrap();
    assert!(repo.is_setup_complete().await.unwrap());
}

#[tokio::test]
async fn health_has_no_server_header_leak() {
    let app = test_app().await;
    let res = send(&app, get("/health")).await;
    assert_eq!(res.status(), StatusCode::OK);
    // No session cookie is set on a public endpoint.
    assert!(res.headers().get(header::SET_COOKIE).is_none());
}

fn post_form(uri: &str, fields: &[(&str, &str)]) -> Request<Body> {
    let mut body = String::new();
    for (i, (k, v)) in fields.iter().enumerate() {
        if i > 0 {
            body.push('&');
        }
        body.push_str(k);
        body.push('=');
        body.push_str(v);
    }
    Request::builder()
        .method("POST")
        .uri(uri)
        .header(header::CONTENT_TYPE, "application/x-www-form-urlencoded")
        .body(Body::from(body))
        .unwrap()
}

fn with_cookie(mut req: Request<Body>, cookie: &str) -> Request<Body> {
    req.headers_mut()
        .insert(header::COOKIE, cookie.parse().unwrap());
    req
}

/// Grab the `causelog_session=...` cookie value from a Set-Cookie response header.
fn session_cookie_value(res: &axum::response::Response) -> String {
    let raw = res
        .headers()
        .get(header::SET_COOKIE)
        .unwrap()
        .to_str()
        .unwrap();
    raw.split(';')
        .next()
        .unwrap()
        .strip_prefix("causelog_session=")
        .unwrap()
        .to_string()
}

fn redirect_to(res: &axum::response::Response) -> String {
    res.headers()
        .get(header::LOCATION)
        .unwrap()
        .to_str()
        .unwrap()
        .to_string()
}

async fn setup_via_form(router: &axum::Router) -> String {
    let res = send(
        router,
        post_form(
            "/setup",
            &[
                ("username", "dev"),
                ("display", "Dev"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER, "setup should redirect");
    session_cookie(&session_cookie_value(&res))
}

/// Create a user directly via the repository, approve them, create a session,
/// and return the full cookie header value.
async fn create_approved_user(
    repo: &Arc<dyn Repository>,
    username: &str,
    display: &str,
    password: &str,
) -> String {
    let hash = causelog_server::auth::hash_password(password).unwrap();
    let user = repo.create_user(username, display, &hash).await.unwrap();
    repo.approve_user(user.id).await.unwrap();
    let session = repo.create_session(user.id).await.unwrap();
    session_cookie(&session.token)
}

/// Create a user directly via the repository (unapproved), create a session,
/// and return the full cookie header value.
async fn create_unapproved_user(
    repo: &Arc<dyn Repository>,
    username: &str,
    display: &str,
    password: &str,
) -> String {
    let hash = causelog_server::auth::hash_password(password).unwrap();
    let user = repo.create_user(username, display, &hash).await.unwrap();
    let session = repo.create_session(user.id).await.unwrap();
    session_cookie(&session.token)
}

/// Get a CSRF token from a GET request (typically the dashboard).
async fn csrf_from_page(router: &axum::Router, cookie: &str) -> String {
    let dash = send(router, with_cookie(get("/dashboard"), cookie)).await;
    extract_csrf(&body_string(dash).await)
}

#[tokio::test]
async fn setup_creates_user_and_session() {
    let app = test_app().await;

    let res = send(&app, get("/")).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/setup");

    let cookie = setup_via_form(&app).await;
    assert!(!cookie.is_empty());

    let res = send(&app, with_cookie(get("/"), &cookie)).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard");
}

#[tokio::test]
async fn setup_redirects_to_login_when_complete() {
    let app = test_app().await;
    setup_via_form(&app).await;
    let res = send(&app, get("/setup")).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login");
}

#[tokio::test]
async fn setup_validates_input() {
    let app = test_app().await;
    let res = send(
        &app,
        post_form(
            "/setup",
            &[
                ("username", "Bad Name!"),
                ("display", "Dev"),
                ("password", "short"),
                ("confirm", "different"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(
        body.contains("Username must use only lowercase"),
        "got: {body}"
    );
}

#[tokio::test]
async fn setup_preserves_username_on_error() {
    let app = test_app().await;
    let res = send(
        &app,
        post_form(
            "/setup",
            &[
                ("username", "dev"),
                ("display", "Dev"),
                ("password", "short"),
                ("confirm", "short"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;

    // What you typed survives so the failure isn't wasted.
    assert!(body.contains(r#"value="dev""#), "username kept: {body}");
    assert!(body.contains(r#"value="Dev""#), "display kept: {body}");

    // The password field has the visibility toggle but stays masked by default
    // and is never echoed back.
    assert_eq!(
        body.matches("class=\"toggle-pw\"").count(),
        2,
        "one toggle per password field: {body}"
    );
    assert!(
        body.contains(r#"data-target="password""#),
        "toggle targets the field: {body}"
    );
    assert!(
        body.contains(r#"type="password""#),
        "password stays masked: {body}"
    );
    assert!(
        !body.contains(r#"value="short""#),
        "password must not be echoed: {body}"
    );
}

#[tokio::test]
async fn login_keeps_username_on_failure() {
    let app = test_app().await;
    setup_via_form(&app).await;

    let res = send(
        &app,
        post_form("/login", &[("username", "dev"), ("password", "wrongpass")]),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("invalid username or password"), "got: {body}");
    assert!(
        body.contains(r#"value="dev""#),
        "username kept on failure: {body}"
    );
    assert!(
        body.contains("class=\"toggle-pw\""),
        "toggle present: {body}"
    );
    assert!(
        !body.contains(r#"value="wrongpass""#),
        "password must not be echoed: {body}"
    );
}

#[tokio::test]
async fn login_flow() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    let res = send(&app, with_cookie(get("/login"), &cookie)).await;
    assert_eq!(
        res.status(),
        StatusCode::SEE_OTHER,
        "already authed redirects"
    );

    let bad = send(
        &app,
        post_form("/login", &[("username", "dev"), ("password", "wrong")]),
    )
    .await;
    assert_eq!(bad.status(), StatusCode::OK);
    assert!(
        body_string(bad)
            .await
            .contains("invalid username or password")
    );

    let good = send(
        &app,
        post_form(
            "/login",
            &[("username", "dev"), ("password", "longenough1")],
        ),
    )
    .await;
    assert_eq!(good.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&good), "/dashboard");
    let cookie = session_cookie_value(&good);
    assert!(!cookie.is_empty());
}

#[tokio::test]
async fn logout_requires_csrf_and_clears_session() {
    use causelog_server::auth::hash_password;

    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    let hash = hash_password("longenough1").unwrap();
    let user = repo.create_first_user("dev", "Dev", &hash).await.unwrap();
    let session = repo.create_session(user.id).await.unwrap();
    let app = app(repo_box(repo));
    let cookie = format!("causelog_session={}", session.token);

    // No CSRF token -> 403.
    let no_csrf = send(&app, with_cookie(post_form("/logout", &[]), &cookie)).await;
    assert_eq!(no_csrf.status(), StatusCode::FORBIDDEN);

    // Wrong CSRF token -> 403.
    let wrong = send(
        &app,
        with_cookie(post_form("/logout", &[("csrf_token", "bogus")]), &cookie),
    )
    .await;
    assert_eq!(wrong.status(), StatusCode::FORBIDDEN);

    // Correct CSRF token -> logged out and session deleted.
    let ok = send(
        &app,
        with_cookie(
            post_form("/logout", &[("csrf_token", &session.csrf)]),
            &cookie,
        ),
    )
    .await;
    assert_eq!(ok.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&ok), "/login?flash=logged_out");

    let gone = send(&app, with_cookie(get("/login"), &cookie)).await;
    assert_eq!(
        gone.status(),
        StatusCode::OK,
        "session is gone, login page renders"
    );
}

#[tokio::test]
async fn anonymous_logout_redirects_to_login() {
    let app = test_app().await;
    let res = send(&app, post_form("/logout", &[])).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login");
}

/// Pull the session's CSRF token out of a rendered page (it lives in hidden
/// form fields).
fn extract_csrf(html: &str) -> String {
    let marker = r#"name="csrf_token" value=""#;
    let start = html.find(marker).expect("csrf field present") + marker.len();
    let rest = &html[start..];
    let end = rest.find('"').expect("closing quote");
    rest[..end].to_string()
}

/// First `href` starting with `prefix`, e.g. `/decisions/<uuid>`.
fn extract_href(html: &str, prefix: &str) -> String {
    let marker = format!("href=\"{prefix}");
    let start = html.find(&marker).expect("link present") + marker.len();
    let rest = &html[start..];
    let end = rest.find('"').expect("closing quote");
    format!("{prefix}{}", &rest[..end])
}

#[tokio::test]
async fn project_and_goal_crud() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    // Dashboard is behind auth.
    let res = send(&app, get("/dashboard")).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login?flash=not_authorized");

    // Grab the CSRF token from the (authed) dashboard.
    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    assert_eq!(dash.status(), StatusCode::OK);
    let csrf = extract_csrf(&body_string(dash).await);

    // Create a project.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Causelog MVP"),
                    ("summary", "Build the whole thing"),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let project_url = redirect_to(&res);
    assert!(project_url.starts_with("/projects/"));

    // Project page renders the title.
    let page = send(&app, with_cookie(get(&project_url), &cookie)).await;
    assert_eq!(page.status(), StatusCode::OK);
    let body = body_string(page).await;
    assert!(body.contains("Causelog MVP"), "got: {body}");

    // Add a goal.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Reduce recall time"),
                    ("body", "Find a past decision in under a minute"),
                    ("status", "open"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get(&project_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Reduce recall time"), "got: {body}");

    // Dashboard shows the project.
    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    let body = body_string(dash).await;
    assert!(body.contains("Causelog MVP"), "got: {body}");

    // Missing CSRF on a mutating request is rejected.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &project_url,
                &[
                    ("csrf_token", ""),
                    ("title", "x"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::FORBIDDEN);

    // Delete the project.
    let res = send(
        &app,
        with_cookie(
            post_form(&format!("{project_url}/delete"), &[("csrf_token", &csrf)]),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard?flash=deleted");

    // Project page now 404s.
    let res = send(&app, with_cookie(get(&project_url), &cookie)).await;
    assert_eq!(res.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn dashboard_create_form_has_visible_title() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    // The dashboard's create-project form must expose a real, visible title
    // field — not a hidden empty one (that made the UI unable to create
    // projects while claiming "A title is required").
    let res = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(
        body.contains(r#"form method="post" action="/projects""#),
        "create form posts to /projects: {body}"
    );
    assert!(
        body.contains(r#"name="title" required"#),
        "visible title input present: {body}"
    );
    assert!(
        !body.contains(r#"type="hidden" name="title""#),
        "title must not be a hidden input: {body}"
    );
    assert!(
        !body.contains("<details class=\"create-project\" open"),
        "form closed by default: {body}"
    );

    // After a rejected empty-title submit the form is opened automatically, so
    // the "title is required" flash is immediately actionable.
    let res = send(
        &app,
        with_cookie(get("/dashboard?flash=invalid_title"), &cookie),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(
        body.contains("<details class=\"create-project\" open"),
        "form auto-opens after invalid_title: {body}"
    );
    assert!(
        body.contains("A title is required."),
        "flash rendered: {body}"
    );
}

#[tokio::test]
async fn decision_lifecycle_with_history() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    let csrf = extract_csrf(&body_string(dash).await);

    // Create a project.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Storage"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let project_url = redirect_to(&res);
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Create a decision with one option.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/decisions"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Which datastore?"),
                    ("context", "We need persistence."),
                    ("goal_id", ""),
                    ("opt_1_label", "SQLite"),
                    ("opt_1_pros", "Zero ops"),
                    ("opt_1_cons", "Single writer"),
                    ("opt_2_label", ""),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/decisions?flash=decision_created")
    );

    // The decisions page links to the new decision.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let decision_url = extract_href(&body, "/decisions/");
    assert!(decision_url.starts_with("/decisions/"), "got: {body}");

    // Decision page renders title, options, and the initial revision.
    let page = send(&app, with_cookie(get(&decision_url), &cookie)).await;
    assert_eq!(page.status(), StatusCode::OK);
    let body = body_string(page).await;
    assert!(body.contains("Which datastore?"), "got: {body}");
    assert!(body.contains("SQLite"), "got: {body}");
    assert!(body.contains("History"), "got: {body}");

    // Resolve it.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{decision_url}/resolve"),
                &[
                    ("csrf_token", &csrf),
                    ("status", "decided"),
                    ("decided_option", "o1"),
                    ("rationale", "Single user, so one writer is fine."),
                    ("review_at", "2026-12-31"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Page now shows the decision and the review date.
    let page = send(&app, with_cookie(get(&decision_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Chose"), "got: {body}");
    assert!(body.contains("2026-12-31"), "got: {body}");
    // Two revisions: creation + resolution.
    assert_eq!(body.matches("details class").count(), 0);
    let revisions: Vec<_> = body.match_indices("History").collect();
    assert!(!revisions.is_empty(), "got: {body}");
    // The resolution snapshot should be in history.
    assert!(
        body.contains("Single user, so one writer is fine."),
        "got: {body}"
    );

    // The decisions page lists the decided decision.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("Which datastore?"), "got: {body}");
    assert!(body.contains("status-decided"), "got: {body}");
}

#[tokio::test]
async fn experiment_lifecycle_and_timeline() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    let csrf = extract_csrf(&body_string(dash).await);

    // Create a project.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "SQLite trial"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let project_url = redirect_to(&res);
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Create an experiment.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/experiments"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL speeds up reads."),
                    ("goal_id", ""),
                    ("decision_id", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/experiments?flash=experiment_created")
    );

    // The experiments page links to the experiment.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/experiments")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let exp_url = extract_href(&body, "/experiments/");
    assert!(exp_url.starts_with("/experiments/"), "got: {body}");

    // Experiment page shows title, hypothesis, planned status.
    let page = send(&app, with_cookie(get(&exp_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("WAL trial"), "got: {body}");
    assert!(body.contains("WAL speeds up reads."), "got: {body}");
    assert!(body.contains("status-planned"), "got: {body}");

    // Start running.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &exp_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL speeds up reads."),
                    ("status", "running"),
                    ("result", ""),
                    ("lesson", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Log a measurement.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{exp_url}/events"),
                &[
                    ("csrf_token", &csrf),
                    ("kind", "measurement"),
                    ("at_date", ""),
                    ("note", "Read latency halved."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Finish it with a result and lesson.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &exp_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL speeds up reads."),
                    ("status", "done"),
                    ("result", "Reads got 2x faster."),
                    ("lesson", "WAL is worth enabling."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // The page now shows result, lesson, the measurement, and lifecycle dates.
    let page = send(&app, with_cookie(get(&exp_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Reads got 2x faster."), "got: {body}");
    assert!(body.contains("WAL is worth enabling."), "got: {body}");
    assert!(body.contains("Read latency halved."), "got: {body}");
    assert!(body.contains("started"), "got: {body}");
    assert!(body.contains("ended"), "got: {body}");

    // The timeline tells the story in order.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/timeline")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let started = body
        .find("kind-experiment_started")
        .expect("started marker");
    let measured = body.find("kind-measurement").expect("measurement");
    let ended = body.find("kind-experiment_ended").expect("ended marker");
    assert!(
        ended < measured && measured < started,
        "timeline is newest-first, got started={started} measured={measured} ended={ended}"
    );
    assert!(body.contains("Completed “WAL trial”"), "got: {body}");
    assert!(body.contains("Read latency halved."), "got: {body}");

    // The overview no longer carries statistics; they live on the stats page.
    let page = send(&app, with_cookie(get(&project_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(
        !body.contains("Goals completed"),
        "stats left on overview: got: {body}"
    );

    // The statistics page reflects the lifecycle counts.
    let stats_url = format!("{project_url}/stats");
    let page = send(&app, with_cookie(get(&stats_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Goals completed"), "got: {body}");
    assert!(body.contains("Decisions decided"), "got: {body}");
    assert!(body.contains("0/0 (0%)"), "goals progress: got: {body}");
    assert!(
        body.contains("abandoned"),
        "experiment statuses: got: {body}"
    );
    assert!(body.contains("observations"), "got: {body}");
    assert!(
        body.contains("<span class=\"stat\">1</span>"),
        "done experiment count: got: {body}"
    );
}

#[tokio::test]
async fn knowledge_capture_and_graph() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    let csrf = extract_csrf(&body_string(dash).await);

    // Project with a goal.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Causelog"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let project_url = redirect_to(&res);
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Recall decisions fast"),
                    ("body", ""),
                    ("status", "open"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let goal_id = {
        let marker = r#"href="/goals/"#;
        let start = body.find(marker).expect("goal link") + marker.len();
        let rest = &body[start..];
        let end = rest.find('"').expect("closing quote");
        rest[..end].to_string()
    };

    // Decision serving the goal.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/decisions"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Which datastore?"),
                    ("context", ""),
                    ("goal_id", &goal_id),
                    ("opt_1_label", "SQLite"),
                    ("opt_1_pros", ""),
                    ("opt_1_cons", ""),
                    ("opt_2_label", "Postgres"),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let decision_url = extract_href(&body, "/decisions/");
    let decision_id = decision_url
        .strip_prefix("/decisions/")
        .unwrap()
        .to_string();

    // The goal opens to its own page, listing what serves it.
    let page = send(
        &app,
        with_cookie(get(&format!("/goals/{goal_id}")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("Recall decisions fast"), "got: {body}");
    assert!(body.contains("status-open"), "got: {body}");
    assert!(body.contains("Served by decisions"), "got: {body}");
    assert!(body.contains("Which datastore?"), "got: {body}");
    assert!(
        body.contains(&format!(r#"action="{project_url}/goals/{goal_id}""#)),
        "goal edit form: got: {body}"
    );

    // Experiment resolving the decision; capture its lesson as a note.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/experiments"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL is faster."),
                    ("goal_id", &goal_id),
                    ("decision_id", &decision_id),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/experiments")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let exp_url = extract_href(&body, "/experiments/");

    // Lesson must exist before extraction; write one via the edit form.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &exp_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL is faster."),
                    ("status", "done"),
                    ("result", "Reads got 2x faster."),
                    ("lesson", "WAL is worth enabling."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let res = send(
        &app,
        with_cookie(
            post_form(&format!("{exp_url}/extract"), &[("csrf_token", &csrf)]),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let note_url = redirect_to(&res);

    // The note shows the lesson and points back at its experiment source.
    let page = send(&app, with_cookie(get(&note_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Lesson: WAL trial"), "got: {body}");
    assert!(body.contains("WAL is worth enabling."), "got: {body}");
    assert!(body.contains("captured from"), "got: {body}");
    assert!(body.contains(&format!("href=\"{exp_url}\"")), "got: {body}");
    // A revision snapshot was recorded.
    assert!(body.contains("History"), "got: {body}");

    // The graph shows all four node types and the implicit edges.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/graph")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    for marker in [
        "node-goal",
        "node-decision",
        "node-experiment",
        "node-note",
        "edge-tests",
        "edge-from",
    ] {
        assert!(body.contains(marker), "{marker} missing: {body}");
    }

    // Explicit link note → decision via the combined type:uuid selects.
    let note_id = note_url
        .split('?')
        .next()
        .unwrap()
        .strip_prefix("/notes/")
        .unwrap()
        .to_string();
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/links"),
                &[
                    ("csrf_token", &csrf),
                    ("from", &format!("note:{note_id}")),
                    ("to", &format!("decision:{decision_id}")),
                    ("kind", "supports"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/graph?flash=link_created")
    );

    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/graph")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("edge-supports"), "got: {body}");
    assert!(body.contains("Lesson: WAL trial"), "got: {body}");

    // Delete the link.
    let link_form = {
        let dash = send(
            &app,
            with_cookie(get(&format!("{project_url}/graph")), &cookie),
        )
        .await;
        let body = body_string(dash).await;
        let marker = "action=\"/projects/";
        let start = body.find(marker).expect("link form") + marker.len();
        let rest = &body[start..];
        let end = rest.find("/delete\"").expect("delete form");
        rest[..end].to_string()
    };
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/projects/{link_form}/delete"),
                &[("csrf_token", &csrf)],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/graph")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(!body.contains("edge-supports"), "got: {body}");
}

#[tokio::test]
async fn full_text_search() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;

    let dash = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    let csrf = extract_csrf(&body_string(dash).await);

    // A project and a note whose body has a distinctive token.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Storage"),
                    ("summary", "The storage experiment series."),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let project_url = redirect_to(&res);
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL lesson"),
                    ("body", "Zorbium wal improves reads enormously."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let note_url = redirect_to(&res);
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Searching for the distinctive token finds the note via FTS.
    let page = send(&app, with_cookie(get("/search?q=zorbium"), &cookie)).await;
    assert_eq!(page.status(), StatusCode::OK);
    let body = body_string(page).await;
    assert!(body.contains("WAL lesson"), "got: {body}");
    assert!(body.contains("node-note"), "got: {body}");
    assert!(body.contains("<mark>Zorbium</mark>"), "got: {body}");

    // The trigger keeps the index in sync on update.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &note_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL lesson"),
                    ("body", "Now it's all about quxple reads."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get("/search?q=zorbium"), &cookie)).await;
    let body = body_string(page).await;
    assert!(
        !body.contains("WAL lesson"),
        "stale index after update: {body}"
    );
    let page = send(&app, with_cookie(get("/search?q=quxple"), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("WAL lesson"), "got: {body}");

    // ...and on delete.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{}/delete", note_url.split('?').next().unwrap()),
                &[("csrf_token", &csrf)],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get("/search?q=quxple"), &cookie)).await;
    let body = body_string(page).await;
    assert!(
        !body.contains("WAL lesson"),
        "stale index after delete: {body}"
    );

    // Empty query renders the empty state without errors.
    let page = send(&app, with_cookie(get("/search?q="), &cookie)).await;
    assert_eq!(page.status(), StatusCode::OK);
}

#[tokio::test]
async fn setup_cannot_create_second_user() {
    let app = test_app().await;
    let first = setup_via_form(&app).await;
    assert!(!first.is_empty());

    // POSTing /setup again after completion redirects to /login; no second
    // account is created.
    let res = send(
        &app,
        post_form(
            "/setup",
            &[
                ("username", "other"),
                ("display", "Other"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login");
}

#[tokio::test]
async fn secure_mode_sets_secure_cookie() {
    use causelog_server::app_secure;

    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    let app = app_secure(repo_box(repo));

    let res = send(
        &app,
        post_form(
            "/setup",
            &[
                ("username", "dev"),
                ("display", "Dev"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let set_cookie = res
        .headers()
        .get(header::SET_COOKIE)
        .unwrap()
        .to_str()
        .unwrap()
        .to_string();
    assert!(
        set_cookie.contains("; Secure"),
        "HTTPS mode must set Secure cookies: {set_cookie}"
    );
}

/// Create a project and return `(project_url, csrf, cookie)`.
async fn setup_project(app: &axum::Router, cookie: &str) -> (String, String, String) {
    let dash = send(app, with_cookie(get("/dashboard"), cookie)).await;
    let csrf = extract_csrf(&body_string(dash).await);
    let res = send(
        app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Storage"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            cookie,
        ),
    )
    .await;
    let project_url = redirect_to(&res);
    (project_url, csrf, cookie.to_string())
}

#[tokio::test]
async fn decision_update_appends_revision() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_url, csrf, cookie) = setup_project(&app, &cookie).await;

    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/decisions"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Which datastore?"),
                    ("context", "Original context."),
                    ("goal_id", ""),
                    ("opt_1_label", "SQLite"),
                    ("opt_1_pros", ""),
                    ("opt_1_cons", ""),
                    ("opt_2_label", ""),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let decision_url = extract_href(&body, "/decisions/");

    // Edit the title + context.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &decision_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "Which datastore? (rev 2)"),
                    ("context", "Edited context."),
                    ("goal_id", ""),
                    ("opt_1_label", "SQLite"),
                    ("opt_1_pros", ""),
                    ("opt_1_cons", ""),
                    ("opt_2_label", ""),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let page = send(&app, with_cookie(get(&decision_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Which datastore? (rev 2)"), "got: {body}");
    // History keeps both snapshots: the original context and the edited one.
    assert!(body.contains("Original context."), "got: {body}");
    assert!(body.contains("Edited context."), "got: {body}");
}

#[tokio::test]
async fn resolve_without_chosen_option_reverts_to_open() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_url, csrf, cookie) = setup_project(&app, &cookie).await;

    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/decisions"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Which datastore?"),
                    ("context", ""),
                    ("goal_id", ""),
                    ("opt_1_label", "SQLite"),
                    ("opt_1_pros", ""),
                    ("opt_1_cons", ""),
                    ("opt_2_label", ""),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER, "decision created");
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &cookie),
    )
    .await;
    let decision_url = extract_href(&body_string(page).await, "/decisions/");

    // status=decided but an empty decided_option: must not stick.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{decision_url}/resolve"),
                &[
                    ("csrf_token", &csrf),
                    ("status", "decided"),
                    ("decided_option", ""),
                    ("rationale", "oops"),
                    ("review_at", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get(&decision_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(
        body.contains("status-open"),
        "resolve without a choice must leave the decision open: {body}"
    );
    assert!(!body.contains("status-decided"), "got: {body}");
}

#[tokio::test]
async fn experiment_delete_removes_it_and_its_events() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_url, csrf, cookie) = setup_project(&app, &cookie).await;

    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/experiments"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL trial"),
                    ("hypothesis", "WAL is faster."),
                    ("goal_id", ""),
                    ("decision_id", ""),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER, "experiment created");
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/experiments")), &cookie),
    )
    .await;
    let exp_url = extract_href(&body_string(page).await, "/experiments/");

    // Log an event so the cascade has something to delete.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{exp_url}/events"),
                &[
                    ("csrf_token", &csrf),
                    ("kind", "measurement"),
                    ("at_date", ""),
                    ("note", "Reads 2x."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get(&exp_url), &cookie)).await;
    assert!(body_string(page).await.contains("Reads 2x."));

    let res = send(
        &app,
        with_cookie(
            post_form(&format!("{exp_url}/delete"), &[("csrf_token", &csrf)]),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/experiments?flash=experiment_deleted")
    );

    let res = send(&app, with_cookie(get(&exp_url), &cookie)).await;
    assert_eq!(res.status(), StatusCode::NOT_FOUND, "experiment gone");
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/timeline")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(
        !body.contains("Reads 2x."),
        "event must be gone from timeline: {body}"
    );
}

#[tokio::test]
async fn note_update_appends_revision_and_delete_removes() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_url, csrf, cookie) = setup_project(&app, &cookie).await;

    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL lesson"),
                    ("body", "First draft body."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let note_url = redirect_to(&res);
    assert!(note_url.starts_with("/notes/"));

    // Update: history must keep the first draft.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &note_url,
                &[
                    ("csrf_token", &csrf),
                    ("title", "WAL lesson"),
                    ("body", "Second draft body."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get(&note_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Second draft body."), "got: {body}");
    assert!(
        body.contains("First draft body."),
        "history keeps the draft: {body}"
    );

    // Delete.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{}/delete", note_url.split('?').next().unwrap()),
                &[("csrf_token", &csrf)],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let res = send(&app, with_cookie(get(&note_url), &cookie)).await;
    assert_eq!(res.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn links_reject_self_and_bad_entities() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_url, csrf, cookie) = setup_project(&app, &cookie).await;

    // Create two notes to link.
    let mut ids = Vec::new();
    for title in ["Alpha", "Beta"] {
        let res = send(
            &app,
            with_cookie(
                post_form(
                    &format!("{project_url}/notes"),
                    &[("csrf_token", &csrf), ("title", title), ("body", "body")],
                ),
                &cookie,
            ),
        )
        .await;
        let url = redirect_to(&res);
        ids.push(
            url.split('?')
                .next()
                .unwrap()
                .strip_prefix("/notes/")
                .unwrap()
                .to_string(),
        );
    }

    // Self-link is rejected as invalid.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/links"),
                &[
                    ("csrf_token", &csrf),
                    ("from", &format!("note:{}", ids[0])),
                    ("to", &format!("note:{}", ids[0])),
                    ("kind", "supports"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/graph?flash=invalid_link")
    );

    // Non-linkable entity type (goal) is rejected.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/links"),
                &[
                    ("csrf_token", &csrf),
                    ("from", &format!("note:{}", ids[0])),
                    ("to", "goal:not-a-uuid"),
                    ("kind", "supports"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/graph?flash=invalid_link")
    );

    // A valid link between two notes works.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/links"),
                &[
                    ("csrf_token", &csrf),
                    ("from", &format!("note:{}", ids[0])),
                    ("to", &format!("note:{}", ids[1])),
                    ("kind", "follows"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(
        redirect_to(&res),
        format!("{project_url}/graph?flash=link_created")
    );
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/graph")), &cookie),
    )
    .await;
    assert!(body_string(page).await.contains("edge-follows"));
}

#[tokio::test]
async fn search_is_isolated_per_project() {
    let app = test_app().await;
    let cookie = setup_via_form(&app).await;
    let (project_a, csrf, cookie) = setup_project(&app, &cookie).await;

    // Note in project A with a distinctive token.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_a}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "A secret"),
                    ("body", "Only zorq here."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Second project, different title.
    let res = send(
        &app,
        with_cookie(
            post_form(
                "/projects",
                &[
                    ("csrf_token", &csrf),
                    ("title", "Other"),
                    ("summary", ""),
                    ("status", "active"),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    let project_b = redirect_to(&res);
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_b}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "B secret"),
                    ("body", "Only zorq here."),
                ],
            ),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // The same token appears in both projects' notes: both must be found.
    let page = send(&app, with_cookie(get("/search?q=zorq"), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("A secret"), "got: {body}");
    assert!(body.contains("B secret"), "got: {body}");

    // Deleting note A must not disturb note B's index entry.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_a}/notes")), &cookie),
    )
    .await;
    let body = body_string(page).await;
    let note_url = extract_href(&body, "/notes/");
    let res = send(
        &app,
        with_cookie(
            post_form(&format!("{note_url}/delete"), &[("csrf_token", &csrf)]),
            &cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let page = send(&app, with_cookie(get("/search?q=zorq"), &cookie)).await;
    let body = body_string(page).await;
    assert!(!body.contains("A secret"), "got: {body}");
    assert!(body.contains("B secret"), "got: {body}");
}

// ===========================================================================
// Multi-user integration tests
// ===========================================================================

#[tokio::test]
async fn register_creates_pending_user() {
    let (app, repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    let res = send(
        &app,
        post_form(
            "/register",
            &[
                ("username", "alice"),
                ("display", "Alice"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login?flash=registered");
    // User exists but is not approved
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    assert!(!alice.approved);
    assert_eq!(alice.role, "user");
}

#[tokio::test]
async fn register_rejects_duplicate_username() {
    let (app, _repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    // Register alice
    send(
        &app,
        post_form(
            "/register",
            &[
                ("username", "alice"),
                ("display", "Alice"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    // Register alice again
    let res = send(
        &app,
        post_form(
            "/register",
            &[
                ("username", "alice"),
                ("display", "Alice2"),
                ("password", "longenough1"),
                ("confirm", "longenough1"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("already taken"), "got: {body}");
}

#[tokio::test]
async fn register_validates_input() {
    let (_app, _repo) = test_app_with_repo().await;
    let res = send(
        &_app,
        post_form(
            "/register",
            &[
                ("username", "ab"),
                ("display", ""),
                ("password", "short"),
                ("confirm", "different"),
            ],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("at least 3 characters"), "got: {body}");
}

#[tokio::test]
async fn unapproved_user_cannot_login() {
    let (app, repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    create_unapproved_user(&repo, "alice", "Alice", "longenough1").await;
    let res = send(
        &app,
        post_form(
            "/login",
            &[("username", "alice"), ("password", "longenough1")],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("pending admin approval"), "got: {body}");
}

#[tokio::test]
async fn unapproved_user_redirected_from_dashboard() {
    let (app, repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    let cookie = create_unapproved_user(&repo, "alice", "Alice", "longenough1").await;
    let res = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/login?flash=not_approved");
}

#[tokio::test]
async fn approved_user_can_login_and_see_dashboard() {
    let (app, repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    let cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let res = send(&app, with_cookie(get("/dashboard"), &cookie)).await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("Dashboard"), "got: {body}");
}

#[tokio::test]
async fn admin_users_page_requires_admin() {
    let (app, repo) = test_app_with_repo().await;
    setup_via_form(&app).await;
    let cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let res = send(&app, with_cookie(get("/admin/users"), &cookie)).await;
    // Non-admin gets redirected
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard?flash=access_denied");
}

#[tokio::test]
async fn admin_can_approve_user() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    create_unapproved_user(&repo, "alice", "Alice", "longenough1").await;
    // Get alice's ID
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    // Approve via admin route
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/approve"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/admin/users?flash=approved");
    // Alice can now login
    let res = send(
        &app,
        post_form(
            "/login",
            &[("username", "alice"), ("password", "longenough1")],
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard");
}

#[tokio::test]
async fn admin_can_reject_user() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    create_unapproved_user(&repo, "alice", "Alice", "longenough1").await;
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/reject"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/admin/users?flash=rejected");
    // Alice is deleted
    let users = repo.list_users().await.unwrap();
    assert!(!users.iter().any(|u| u.username == "alice"));
}

#[tokio::test]
async fn admin_can_toggle_role() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    // Toggle to admin
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    assert_eq!(alice.role, "admin");
    // Toggle back to user
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    assert_eq!(alice.role, "user");
}

#[tokio::test]
async fn admin_can_delete_user() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/delete"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    let users = repo.list_users().await.unwrap();
    assert!(!users.iter().any(|u| u.username == "alice"));
}

#[tokio::test]
async fn admin_cannot_demote_last_admin() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    // Get the admin's own ID.
    let users = repo.list_users().await.unwrap();
    let admin = users.iter().find(|u| u.username == "dev").unwrap();
    let admin_id = admin.id.to_string();
    assert_eq!(admin.role, "admin");
    // Try to demote self — the only admin.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{admin_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(
        redirect_to(&res).contains("cannot_demote_last_admin"),
        "got: {}",
        redirect_to(&res)
    );
    // Admin is still admin.
    let users = repo.list_users().await.unwrap();
    let admin = users.iter().find(|u| u.username == "dev").unwrap();
    assert_eq!(admin.role, "admin");
}

#[tokio::test]
async fn admin_can_demote_when_two_admins() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    // Create Alice and promote her to admin.
    create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    // Now demote Alice back — there are two admins, so this should work.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("role_updated"));
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    assert_eq!(alice.role, "user");
}

#[tokio::test]
async fn admin_cannot_delete_last_admin() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    // Verify there's exactly one admin.
    assert_eq!(repo.count_admins().await.unwrap(), 1);
    // The only admin tries to delete themselves — blocked by self-delete guard.
    let users = repo.list_users().await.unwrap();
    let admin = users.iter().find(|u| u.username == "dev").unwrap();
    let admin_id = admin.id.to_string();
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{admin_id}/delete"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("cannot_delete_self"));
    // Admin still exists and is still the only admin.
    assert_eq!(repo.count_admins().await.unwrap(), 1);
}

#[tokio::test]
async fn admin_can_delete_when_two_admins() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    // Promote Alice to admin.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/role"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    // Delete Alice — two admins exist, so this should work.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{alice_id}/delete"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("deleted"));
    let users = repo.list_users().await.unwrap();
    assert!(!users.iter().any(|u| u.username == "alice"));
}

#[tokio::test]
async fn dashboard_scopes_projects_for_non_admin() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    // Admin creates a project
    let _project_url = create_project(&app, &admin_cookie, "Secret Project", "active").await;
    // Alice should NOT see it on her dashboard
    let res = send(&app, with_cookie(get("/dashboard"), &alice_cookie)).await;
    let body = body_string(res).await;
    assert!(
        !body.contains("Secret Project"),
        "alice should not see admin project"
    );
}

#[tokio::test]
async fn dashboard_shows_all_for_admin() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    // Alice creates a project
    let _project_url = create_project(&app, &alice_cookie, "Alice Project", "active").await;
    // Admin should see it
    let res = send(&app, with_cookie(get("/dashboard"), &admin_cookie)).await;
    let body = body_string(res).await;
    assert!(
        body.contains("Alice Project"),
        "admin should see all projects"
    );
}

#[tokio::test]
async fn non_member_cannot_view_project() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Secret Project", "active").await;
    // Alice should be blocked
    let res = send(&app, with_cookie(get(&project_url), &alice_cookie)).await;
    assert_eq!(res.status(), StatusCode::FORBIDDEN);
}

#[tokio::test]
async fn non_member_cannot_create_goal() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Secret Project", "active").await;
    let csrf = csrf_from_page(&app, &alice_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "New Goal"),
                    ("body", ""),
                    ("status", "open"),
                ],
            ),
            &alice_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard?flash=access_denied");
}

#[tokio::test]
async fn member_can_view_project() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Shared Project", "active").await;
    // Add alice as member
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    repo.add_project_member(Uuid::parse_str(project_id).unwrap(), alice.id, "member")
        .await
        .unwrap();
    // Alice can now view the project
    let res = send(&app, with_cookie(get(&project_url), &alice_cookie)).await;
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_string(res).await;
    assert!(body.contains("Shared Project"), "got: {body}");
}

#[tokio::test]
async fn owner_can_add_and_remove_members() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let _alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Team Project", "active").await;
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    // Get alice's ID
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    // Add alice as member
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/members"),
                &[("csrf_token", &csrf), ("user_id", &alice_id)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("member_added"));
    // Verify membership
    assert!(
        repo.is_project_member(alice.id, Uuid::parse_str(project_id).unwrap())
            .await
            .unwrap()
    );
    // Remove alice
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/members/{alice_id}/remove"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("member_removed"));
    assert!(
        !repo
            .is_project_member(alice.id, Uuid::parse_str(project_id).unwrap())
            .await
            .unwrap()
    );
}

#[tokio::test]
async fn cannot_remove_last_owner() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let project_url = create_project(&app, &admin_cookie, "Only Owner", "active").await;
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    // Get admin's ID
    let users = repo.list_users().await.unwrap();
    let admin = users.iter().find(|u| u.username == "dev").unwrap();
    let admin_id = admin.id.to_string();
    // Try to remove self (the only owner)
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/members/{admin_id}/remove"),
                &[("csrf_token", &csrf)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert!(redirect_to(&res).contains("cannot_remove_last_owner"));
    // Owner still exists
    assert!(
        repo.is_project_member(admin.id, Uuid::parse_str(project_id).unwrap())
            .await
            .unwrap()
    );
}

#[tokio::test]
async fn non_member_cannot_access_decision() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Secret", "active").await;
    // Admin creates a decision
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/decisions"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Important Decision"),
                    ("context", "Because"),
                    ("goal_id", ""),
                    ("opt_1_label", "A"),
                    ("opt_1_pros", ""),
                    ("opt_1_cons", ""),
                    ("opt_2_label", "B"),
                    ("opt_2_pros", ""),
                    ("opt_2_cons", ""),
                    ("opt_3_label", ""),
                    ("opt_3_pros", ""),
                    ("opt_3_cons", ""),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    // Get decision URL from decisions page
    let dec_page = send(
        &app,
        with_cookie(get(&format!("{project_url}/decisions")), &admin_cookie),
    )
    .await;
    let body = body_string(dec_page).await;
    let dec_url = extract_href(&body, "/decisions/");
    // Alice cannot view the decision
    let res = send(&app, with_cookie(get(&dec_url), &alice_cookie)).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard?flash=access_denied");
}

// ===========================================================================
// Goal assignment tests
// ===========================================================================

/// Helper: extract a UUID from an href like `href="/goals/<uuid>"`.
fn extract_goal_id(html: &str) -> String {
    let marker = r#"href="/goals/"#;
    let start = html.find(marker).expect("goal link") + marker.len();
    let rest = &html[start..];
    let end = rest.find('"').expect("closing quote");
    rest[..end].to_string()
}

#[tokio::test]
async fn goal_assignment_on_create() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let _alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Team Project", "active").await;

    // Add alice as member.
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    repo.add_project_member(Uuid::parse_str(project_id).unwrap(), alice.id, "member")
        .await
        .unwrap();

    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Ship feature X"),
                    ("body", "Critical deliverable"),
                    ("status", "open"),
                    ("assigned_to", &alice_id),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Get the goal URL from the goals page.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &admin_cookie),
    )
    .await;
    let body = body_string(page).await;
    let goal_id = extract_goal_id(&body);
    let goal_url = format!("/goals/{goal_id}");

    // Goal detail page shows the assignee.
    let page = send(&app, with_cookie(get(&goal_url), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("assigned to Alice"), "got: {body}");

    // Goal list on the project page also shows the assignee.
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &admin_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("→ Alice"), "assignee in list: {body}");
}

#[tokio::test]
async fn goal_assignment_update() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let _alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Team Project", "active").await;

    // Add alice as member.
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    repo.add_project_member(Uuid::parse_str(project_id).unwrap(), alice.id, "member")
        .await
        .unwrap();

    let csrf = csrf_from_page(&app, &admin_cookie).await;

    // Create an unassigned goal.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Unassigned work"),
                    ("body", ""),
                    ("status", "open"),
                    ("assigned_to", ""),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &admin_cookie),
    )
    .await;
    let goal_id = extract_goal_id(&body_string(page).await);
    let goal_url = format!("/goals/{goal_id}");

    // Verify unassigned on detail page.
    let page = send(&app, with_cookie(get(&goal_url), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(
        !body.contains("assigned to"),
        "should be unassigned: {body}"
    );

    // Assign to alice via edit form.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals/{goal_id}"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Unassigned work"),
                    ("body", ""),
                    ("status", "open"),
                    ("assigned_to", &alice_id),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let page = send(&app, with_cookie(get(&goal_url), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("assigned to Alice"), "got: {body}");

    // Unassign via edit form.
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals/{goal_id}"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Unassigned work"),
                    ("body", ""),
                    ("status", "open"),
                    ("assigned_to", ""),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let page = send(&app, with_cookie(get(&goal_url), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(
        !body.contains("assigned to"),
        "should be unassigned again: {body}"
    );
}

#[tokio::test]
async fn member_creates_goal_with_assignment() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Team Project", "active").await;

    // Add alice as member.
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let alice_id = alice.id.to_string();
    let project_id = project_url.strip_prefix("/projects/").unwrap();
    repo.add_project_member(Uuid::parse_str(project_id).unwrap(), alice.id, "member")
        .await
        .unwrap();

    // Alice creates a goal and assigns it to herself.
    let csrf = csrf_from_page(&app, &alice_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Self-assigned work"),
                    ("body", "Alice is on it"),
                    ("status", "open"),
                    ("assigned_to", &alice_id),
                ],
            ),
            &alice_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // The goal shows "created by Alice" and "assigned to Alice".
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &alice_cookie),
    )
    .await;
    let body = body_string(page).await;
    let goal_id = extract_goal_id(&body);
    let goal_url = format!("/goals/{goal_id}");

    let page = send(&app, with_cookie(get(&goal_url), &alice_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("created by Alice"), "got: {body}");
    assert!(body.contains("assigned to Alice"), "got: {body}");
}

#[tokio::test]
async fn goal_list_shows_multiple_assignees() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let _alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let _carol_cookie = create_approved_user(&repo, "carol", "Carol", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Team Project", "active").await;

    // Add both as members.
    let users = repo.list_users().await.unwrap();
    let alice = users.iter().find(|u| u.username == "alice").unwrap();
    let carol = users.iter().find(|u| u.username == "carol").unwrap();
    let alice_id = alice.id.to_string();
    let carol_id = carol.id.to_string();
    let project_id = Uuid::parse_str(project_url.strip_prefix("/projects/").unwrap()).unwrap();
    repo.add_project_member(project_id, alice.id, "member")
        .await
        .unwrap();
    repo.add_project_member(project_id, carol.id, "member")
        .await
        .unwrap();

    let csrf = csrf_from_page(&app, &admin_cookie).await;

    // Create goals assigned to different people.
    for (title, assignee) in [("Alice's task", &alice_id), ("Carol's task", &carol_id)] {
        let res = send(
            &app,
            with_cookie(
                post_form(
                    &format!("{project_url}/goals"),
                    &[
                        ("csrf_token", &csrf),
                        ("title", title),
                        ("body", ""),
                        ("status", "open"),
                        ("assigned_to", assignee),
                    ],
                ),
                &admin_cookie,
            ),
        )
        .await;
        assert_eq!(res.status(), StatusCode::SEE_OTHER);
    }

    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &admin_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("→ Alice"), "got: {body}");
    assert!(body.contains("→ Carol"), "got: {body}");
    assert!(body.contains("Alice&#39;s task"), "got: {body}");
    assert!(body.contains("Carol&#39;s task"), "got: {body}");
}

#[tokio::test]
async fn non_member_cannot_see_goal_assignment_dropdown() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let project_url = create_project(&app, &admin_cookie, "Secret Project", "active").await;

    // Create a goal as admin.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Secret Goal"),
                    ("body", ""),
                    ("status", "open"),
                    ("assigned_to", ""),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &admin_cookie),
    )
    .await;
    let goal_id = extract_goal_id(&body_string(page).await);
    let goal_url = format!("/goals/{goal_id}");

    // Alice (non-member) cannot access the goal page.
    let res = send(&app, with_cookie(get(&goal_url), &alice_cookie)).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/dashboard?flash=access_denied");
}

#[tokio::test]
async fn alice_owns_sqlite_project_carol_is_member() {
    // Verify the seed scenario: alice owns SQLite project, carol is a member.
    // We test this through direct DB access since seed runs before tests.
    let (app, repo) = test_app_with_repo().await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;
    let carol_cookie = create_approved_user(&repo, "carol", "Carol", "longenough1").await;

    // Alice creates a project (simulating seed ownership).
    let project_url = create_project(&app, &alice_cookie, "Alice's Project", "active").await;
    let project_id = Uuid::parse_str(project_url.strip_prefix("/projects/").unwrap()).unwrap();

    // Alice adds carol as member.
    repo.add_project_member(
        project_id,
        {
            let users = repo.list_users().await.unwrap();
            users.iter().find(|u| u.username == "carol").unwrap().id
        },
        "member",
    )
    .await
    .unwrap();

    // Both can access the project.
    let res = send(&app, with_cookie(get(&project_url), &alice_cookie)).await;
    assert_eq!(res.status(), StatusCode::OK);
    let res = send(&app, with_cookie(get(&project_url), &carol_cookie)).await;
    assert_eq!(res.status(), StatusCode::OK);

    // Carol can create a goal in alice's project.
    let csrf = csrf_from_page(&app, &carol_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_url}/goals"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Carol's contribution"),
                    ("body", "Helping out"),
                    ("status", "open"),
                    ("assigned_to", ""),
                ],
            ),
            &carol_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // The goal shows "created by Carol".
    let page = send(
        &app,
        with_cookie(get(&format!("{project_url}/goals")), &alice_cookie),
    )
    .await;
    let body = body_string(page).await;
    let goal_id = extract_goal_id(&body);
    let goal_url = format!("/goals/{goal_id}");

    let page = send(&app, with_cookie(get(&goal_url), &alice_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("created by Carol"), "got: {body}");
}

#[tokio::test]
async fn search_scoped_to_user_projects() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;

    // Admin creates two projects with distinctive search terms.
    let project_a = create_project(&app, &admin_cookie, "Alpha", "active").await;
    let project_b = create_project(&app, &admin_cookie, "Beta", "active").await;

    // Note in project A.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_a}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Alpha note"),
                    ("body", "Unique alpha token: flurbex"),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Note in project B.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("{project_b}/notes"),
                &[
                    ("csrf_token", &csrf),
                    ("title", "Beta note"),
                    ("body", "Unique beta token: zymolog"),
                ],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);

    // Add alice as member of project A only.
    let admin_user = repo.list_users().await.unwrap();
    let alice_user = admin_user.iter().find(|u| u.username == "alice").unwrap();
    let a_id = project_a.strip_prefix("/projects/").unwrap();
    repo.add_project_member(
        a_id.parse().unwrap(),
        alice_user.id,
        "member",
    )
    .await
    .unwrap();

    // Admin can search both projects.
    let page = send(
        &app,
        with_cookie(get("/search?q=flurbex"), &admin_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("Alpha note"), "admin should see alpha: {body}");

    let page = send(
        &app,
        with_cookie(get("/search?q=zymolog"), &admin_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(body.contains("Beta note"), "admin should see beta: {body}");

    // Alice searches — should only find project A (her member project).
    let page = send(
        &app,
        with_cookie(get("/search?q=flurbex"), &alice_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(
        body.contains("Alpha note"),
        "alice should see alpha: {body}"
    );

    let page = send(
        &app,
        with_cookie(get("/search?q=zymolog"), &alice_cookie),
    )
    .await;
    let body = body_string(page).await;
    assert!(
        !body.contains("Beta note"),
        "alice must NOT see beta: {body}"
    );
}

#[tokio::test]
async fn admin_add_remove_user_to_project() {
    let (app, repo) = test_app_with_repo().await;
    let admin_cookie = setup_via_form(&app).await;
    let alice_cookie = create_approved_user(&repo, "alice", "Alice", "longenough1").await;

    // Admin creates a project.
    let project_url = create_project(&app, &admin_cookie, "Web Platform", "active").await;
    let project_id = project_url.strip_prefix("/projects/").unwrap();

    // Get alice's user ID.
    let alice_user = repo
        .list_users()
        .await
        .unwrap()
        .into_iter()
        .find(|u| u.username == "alice")
        .unwrap();

    // Admin users page initially shows no projects for alice.
    let page = send(&app, with_cookie(get("/admin/users"), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Alice"), "should show alice: {body}");

    // Add alice to the project via admin endpoint.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{}/add-to-project", alice_user.id),
                &[("csrf_token", &csrf), ("project_id", project_id)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/admin/users?flash=member_added");

    // Admin users page now shows the project for alice.
    let page = send(&app, with_cookie(get("/admin/users"), &admin_cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("Web Platform"), "should show project: {body}");

    // Verify alice can access the project.
    let page = send(&app, with_cookie(get(&project_url), &alice_cookie)).await;
    assert_eq!(page.status(), StatusCode::OK);

    // Remove alice from the project via admin endpoint.
    let csrf = csrf_from_page(&app, &admin_cookie).await;
    let res = send(
        &app,
        with_cookie(
            post_form(
                &format!("/admin/users/{}/remove-from-project", alice_user.id),
                &[("csrf_token", &csrf), ("project_id", project_id)],
            ),
            &admin_cookie,
        ),
    )
    .await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/admin/users?flash=member_removed");

    // Admin users page no longer shows alice as a member of the project.
    // (The project still appears in the dropdown, but not as a membership tag.)
    let page = send(&app, with_cookie(get("/admin/users"), &admin_cookie)).await;
    let body = body_string(page).await;
    // After removal, alice's row should not have a remove-from-project form.
    assert!(
        !body.contains(&format!("/admin/users/{}/remove-from-project", alice_user.id)),
        "alice should not have a remove-from-project form: {body}"
    );

    // Alice can no longer access the project.
    let page = send(&app, with_cookie(get(&project_url), &alice_cookie)).await;
    assert_eq!(page.status(), StatusCode::FORBIDDEN);
}
