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
