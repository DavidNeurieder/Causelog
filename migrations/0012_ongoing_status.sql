-- M12: Add 'ongoing' status to experiments and goals.
-- SQLite does not support ALTER TABLE to modify constraints, so we recreate.

-- ── Experiments: rename 'running' → 'ongoing' ──────────────────────────────
UPDATE experiments SET status = 'ongoing' WHERE status = 'running';

CREATE TABLE IF NOT EXISTS experiments_new (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    goal_id       TEXT REFERENCES goals(id) ON DELETE SET NULL,
    decision_id   TEXT REFERENCES decisions(id) ON DELETE SET NULL,
    title         TEXT NOT NULL,
    hypothesis    TEXT NOT NULL DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'planned'
                  CHECK (status IN ('planned', 'ongoing', 'done', 'abandoned')),
    started_at_ms INTEGER,
    ended_at_ms   INTEGER,
    result        TEXT NOT NULL DEFAULT '',
    lesson        TEXT NOT NULL DEFAULT '',
    created_by    TEXT REFERENCES users(id),
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

INSERT INTO experiments_new
SELECT id, project_id, goal_id, decision_id, title, hypothesis, status,
       started_at_ms, ended_at_ms, result, lesson, created_by, created_at_ms, updated_at_ms
FROM experiments;

DROP TABLE experiments;

ALTER TABLE experiments_new RENAME TO experiments;

CREATE INDEX IF NOT EXISTS idx_experiments_project ON experiments(project_id);

-- ── Goals: add 'ongoing' ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS goals_new (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title         TEXT NOT NULL,
    body          TEXT NOT NULL DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'ongoing', 'done', 'dropped')),
    assigned_to   TEXT REFERENCES users(id),
    created_by    TEXT REFERENCES users(id),
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

INSERT INTO goals_new
SELECT id, project_id, title, body, status, assigned_to, created_by, created_at_ms, updated_at_ms
FROM goals;

DROP TABLE goals;

ALTER TABLE goals_new RENAME TO goals;

CREATE INDEX IF NOT EXISTS idx_goals_project ON goals(project_id);
