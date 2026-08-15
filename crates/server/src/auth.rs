//! Auth: argon2 password hashing, server-side sessions, CSRF, cookies, and the
//! `AuthUser` request extractor (mirroring Forgepost).

use argon2::Argon2;
use argon2::password_hash::{
    PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng,
};
use axum::{
    extract::FromRequestParts,
    http::{HeaderMap, HeaderValue, header, request::Parts},
};
use kaizen_content::now_ms;
use kaizen_model::{Session, User};
use sha2::{Digest, Sha256};
use uuid::Uuid;

use crate::AppState;
use crate::error::ApiError;

pub const SESSION_COOKIE: &str = "kaizen_session";
pub const CSRF_HEADER: &str = "x-csrf-token";
pub const SESSION_TTL_MS: i64 = 30 * 24 * 3600 * 1000;

pub fn hash_password(password: &str) -> Result<String, ApiError> {
    let salt = SaltString::generate(&mut OsRng);
    Argon2::default()
        .hash_password(password.as_bytes(), &salt)
        .map(|h| h.to_string())
        .map_err(|_| ApiError::bad_request("could not hash password"))
}

pub fn verify_password(hash: &str, password: &str) -> bool {
    PasswordHash::new(hash)
        .ok()
        .and_then(|parsed| {
            Argon2::default()
                .verify_password(password.as_bytes(), &parsed)
                .ok()
        })
        .is_some()
}

/// SHA-256 hex digest — session tokens are persisted only as hashes.
pub fn sha256_hex(input: &str) -> String {
    hex::encode(Sha256::digest(input.as_bytes()))
}

/// Read a cookie from a request's headers.
pub fn cookie(headers: &HeaderMap, name: &str) -> Option<String> {
    let value = headers.get(header::COOKIE)?.to_str().ok()?;
    for pair in value.split(';') {
        let pair = pair.trim();
        if let Some((k, v)) = pair.split_once('=')
            && k.trim() == name
        {
            return Some(v.trim().to_string());
        }
    }
    None
}

/// Session cookie value; `secure` appends the `Secure` flag (used once HTTPS
/// is active).
pub fn set_session_cookie_secure(token: &str, secure: bool) -> HeaderValue {
    let secure = if secure { "; Secure" } else { "" };
    HeaderValue::from_str(&format!(
        "{SESSION_COOKIE}={token}; HttpOnly; SameSite=Lax; Path=/; Max-Age={}{secure}",
        SESSION_TTL_MS / 1000
    ))
    .expect("cookie value is valid")
}

pub fn clear_session_cookie_secure(secure: bool) -> HeaderValue {
    let secure = if secure { "; Secure" } else { "" };
    HeaderValue::from_str(&format!(
        "{SESSION_COOKIE}=; HttpOnly; SameSite=Lax; Path=/; Max-Age=0{secure}"
    ))
    .expect("cookie value is valid")
}

/// Require the CSRF token to match the session's. The token may arrive in the
/// `x-csrf-token` header (API clients) or a hidden form field (server-rendered
/// pages).
pub fn verify_csrf_form(
    headers: &HeaderMap,
    form_token: Option<&str>,
    session_csrf: &str,
) -> Result<(), ApiError> {
    let header = headers
        .get(CSRF_HEADER)
        .and_then(|v| v.to_str().ok())
        .unwrap_or_default();
    if header == session_csrf || form_token == Some(session_csrf) {
        Ok(())
    } else {
        Err(ApiError::forbidden())
    }
}

/// Authenticated user extracted from the session cookie.
#[derive(Clone)]
pub struct AuthUser {
    pub user: User,
    pub csrf_token: String,
}

impl AuthUser {
    pub fn new_session(user: User) -> Session {
        Session {
            token: Uuid::new_v4().to_string(),
            csrf: Uuid::new_v4().to_string(),
            user_id: user.id,
            expires_at_ms: now_ms() + SESSION_TTL_MS,
        }
    }
}

/// Resolve the session cookie to an `AuthUser`, or `None` when there is no
/// valid session. Page handlers use this so they can decide to redirect to
/// `/login` instead of returning a 401 JSON error.
pub async fn session_user(state: &AppState, headers: &HeaderMap) -> Option<AuthUser> {
    let token = cookie(headers, SESSION_COOKIE)?;
    let session = state.repo.session_by_token(&token).await.ok()??;
    let user = state.repo.find_user_by_id(session.user_id).await.ok()??;
    Some(AuthUser {
        user,
        csrf_token: session.csrf,
    })
}

impl FromRequestParts<AppState> for AuthUser {
    type Rejection = ApiError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let token = cookie(&parts.headers, SESSION_COOKIE).ok_or_else(ApiError::unauthorized)?;
        let session = state
            .repo
            .session_by_token(&token)
            .await
            .map_err(ApiError::from)?
            .ok_or_else(ApiError::unauthorized)?;
        let user = state
            .repo
            .find_user_by_id(session.user_id)
            .await
            .map_err(ApiError::from)?
            .ok_or_else(ApiError::unauthorized)?;
        Ok(AuthUser {
            user,
            csrf_token: session.csrf,
        })
    }
}
