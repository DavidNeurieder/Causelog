//! Headless JSON endpoints. Pages come later; the MVP also exposes a small
//! JSON API so external tools can script content in.

use axum::Json;

pub async fn health() -> Json<serde_json::Value> {
    Json(serde_json::json!({ "status": "ok" }))
}
