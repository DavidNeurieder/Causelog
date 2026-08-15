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
