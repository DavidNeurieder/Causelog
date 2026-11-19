-- M16: Track idempotency request lifecycle (pending vs completed).

ALTER TABLE idempotency_keys
    ADD COLUMN status TEXT NOT NULL DEFAULT 'completed';

CREATE INDEX IF NOT EXISTS idx_idempotency_status
    ON idempotency_keys(status);