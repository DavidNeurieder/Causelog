-- M6: knowledge — notes (captured lessons, source-linked) and explicit
-- relationships between entities, feeding the project graph.
-- A note is a piece of durable knowledge; when extracted from an experiment it
-- carries a source pointer. Revisions are recorded against entity_type 'note'.

CREATE TABLE IF NOT EXISTS notes (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title         TEXT NOT NULL,
    body          TEXT NOT NULL DEFAULT '',
    -- source: 'experiment' | 'decision' — where this note was captured from.
    source_type   TEXT,
    source_id     TEXT,
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notes_project ON notes(project_id);

CREATE TABLE IF NOT EXISTS links (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    from_type     TEXT NOT NULL CHECK (from_type IN ('note', 'decision', 'experiment')),
    from_id       TEXT NOT NULL,
    to_type       TEXT NOT NULL CHECK (to_type IN ('note', 'decision', 'experiment')),
    to_id         TEXT NOT NULL,
    kind          TEXT NOT NULL DEFAULT 'related'
                  CHECK (kind IN ('related', 'supports', 'rejects', 'follows')),
    created_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_links_from ON links(from_type, from_id);
CREATE INDEX IF NOT EXISTS idx_links_to ON links(to_type, to_id);
