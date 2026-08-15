-- M2: single-user auth. The MVP is single-user-first; the schema still uses a
-- users table so team auth can arrive without a migration.
-- Session tokens are stored as SHA-256 hashes; the raw token lives only in the
-- cookie. Each session carries its own CSRF token.

CREATE TABLE IF NOT EXISTS users (
    id            TEXT PRIMARY KEY NOT NULL,
    username      TEXT NOT NULL UNIQUE,
    display_name  TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at_ms INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    token_hash     TEXT PRIMARY KEY NOT NULL,
    csrf           TEXT NOT NULL,
    user_id        TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at_ms  INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
