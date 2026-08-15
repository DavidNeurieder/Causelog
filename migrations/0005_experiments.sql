-- M5: experiments + events — the timeline/golden path.
-- An experiment tests a hypothesis (often resolving a decision). Its lifecycle
-- (planned → running → done/abandoned) and every observation/measurement are
-- timestamped so the project's timeline reads as a story.

CREATE TABLE IF NOT EXISTS experiments (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    goal_id       TEXT REFERENCES goals(id) ON DELETE SET NULL,
    decision_id   TEXT REFERENCES decisions(id) ON DELETE SET NULL,
    title         TEXT NOT NULL,
    hypothesis    TEXT NOT NULL DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'planned'
                  CHECK (status IN ('planned', 'running', 'done', 'abandoned')),
    started_at_ms INTEGER,
    ended_at_ms   INTEGER,
    result        TEXT NOT NULL DEFAULT '',
    lesson        TEXT NOT NULL DEFAULT '',
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_experiments_project ON experiments(project_id);

CREATE TABLE IF NOT EXISTS events (
    id            TEXT PRIMARY KEY NOT NULL,
    experiment_id TEXT NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
    kind          TEXT NOT NULL CHECK (kind IN ('observation', 'measurement', 'milestone')),
    at_ms         INTEGER NOT NULL,
    note          TEXT NOT NULL DEFAULT '',
    created_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_events_experiment ON events(experiment_id, at_ms);
