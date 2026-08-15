-- M1: minimal storage bootstrap, mirroring Forgepost.
-- Proves the migration + repository path and drives setup status.

CREATE TABLE IF NOT EXISTS settings (
    key        TEXT PRIMARY KEY NOT NULL,
    value      TEXT NOT NULL,
    updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
);

INSERT INTO settings (key, value)
VALUES ('schema.version', '0')
ON CONFLICT(key) DO NOTHING;
