-- M4: immutable revision history. Every change to a decision (later: a note)
-- appends a snapshot here, so the "why did we decide this and when did it
-- change" trail can never be silently rewritten.

CREATE TABLE IF NOT EXISTS revisions (
    id            TEXT PRIMARY KEY NOT NULL,
    entity_type   TEXT NOT NULL CHECK (entity_type IN ('decision', 'note')),
    entity_id     TEXT NOT NULL,
    snapshot      TEXT NOT NULL,
    created_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_revisions_entity
    ON revisions(entity_type, entity_id, created_at_ms);
