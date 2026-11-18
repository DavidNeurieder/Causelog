-- M15: Idempotency keys for safe retries of mutating API requests.
-- Keys are scoped per authenticated user.

CREATE TABLE IF NOT EXISTS idempotency_keys (
    user_id       TEXT    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    idem_key      TEXT    NOT NULL,
    method        TEXT    NOT NULL,
    path          TEXT    NOT NULL,
    request_hash  TEXT    NOT NULL,
    status_code   INTEGER NOT NULL,
    response_body TEXT    NOT NULL,
    created_at_ms INTEGER NOT NULL,
    PRIMARY KEY (user_id, idem_key)
);

CREATE INDEX IF NOT EXISTS idx_idempotency_created
    ON idempotency_keys(created_at_ms);
