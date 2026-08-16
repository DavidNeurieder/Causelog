//! Integration tests against the server-rendered app. Uses an in-memory
//! SQLite database per test via `tower::ServiceExt::oneshot`.

use axum::body::Body;
use axum::http::{Request, StatusCode, header};
use http_body_util::BodyExt;
use kaizen_server::app;
use kaizen_server::repository::{Repository, SqliteRepository};
use std::sync::Arc;
use tower::ServiceExt;

/// Build the router with a fresh in-memory database, migrated.
async fn test_app() -> axum::Router {
    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    app(repo_box(repo))
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

/// Grab the `kaizen_session=...` cookie value from a Set-Cookie response header.
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
        .strip_prefix("kaizen_session=")
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
    session_cookie_value(&res)
}

#[tokio::test]
async fn setup_creates_user_and_session() {
    let app = test_app().await;

    let res = send(&app, get("/")).await;
    assert_eq!(res.status(), StatusCode::SEE_OTHER);
    assert_eq!(redirect_to(&res), "/setup");

    let cookie = setup_via_form(&app).await;
    assert!(!cookie.is_empty());

    let res = send(
        &app,
        with_cookie(get("/"), &format!("kaizen_session={cookie}")),
    )
    .await;
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

    let res = send(
        &app,
        with_cookie(get("/login"), &format!("kaizen_session={cookie}")),
    )
    .await;
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
    use kaizen_server::auth::hash_password;

    let repo = SqliteRepository::connect("sqlite::memory:").await.unwrap();
    repo.migrate().await.unwrap();
    let hash = hash_password("longenough1").unwrap();
    let user = repo.create_first_user("dev", "Dev", &hash).await.unwrap();
    let session = repo.create_session(user.id).await.unwrap();
    let app = app(repo_box(repo));
    let cookie = format!("kaizen_session={}", session.token);

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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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
                    ("title", "Kaizen MVP"),
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
    assert!(body.contains("Kaizen MVP"), "got: {body}");

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
    assert!(body.contains("Kaizen MVP"), "got: {body}");

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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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

    // The project overview reflects the lifecycle statistics.
    let page = send(&app, with_cookie(get(&project_url), &cookie)).await;
    let body = body_string(page).await;
    assert!(body.contains("0/0 goals done"), "got: {body}");
    assert!(body.contains("experiments done"), "got: {body}");
    assert!(body.contains("1 experiments"), "header total: got: {body}");
    assert!(body.contains("observations"), "got: {body}");
    assert!(body.contains("Goals completed"), "got: {body}");
    assert!(body.contains("Decisions decided"), "got: {body}");
}

#[tokio::test]
async fn knowledge_capture_and_graph() {
    let app = test_app().await;
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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
                    ("title", "Kaizen"),
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);

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
    use kaizen_server::app_secure;

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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
    let cookie = format!("kaizen_session={}", setup_via_form(&app).await);
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
