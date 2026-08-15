-- M3: projects, goals, decisions.
-- Decisions are the core Kaizen artifact: a named trade-off with options and,
-- once resolved, a decided option + rationale. History arrives as revisions in
-- a later migration.

CREATE TABLE IF NOT EXISTS projects (
    id            TEXT PRIMARY KEY NOT NULL,
    title         TEXT NOT NULL,
    summary       TEXT NOT NULL DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'paused', 'archived')),
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS goals (
    id            TEXT PRIMARY KEY NOT NULL,
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title         TEXT NOT NULL,
    body          TEXT NOT NULL DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'done', 'dropped')),
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS decisions (
    id             TEXT PRIMARY KEY NOT NULL,
    project_id     TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    goal_id        TEXT REFERENCES goals(id) ON DELETE SET NULL,
    title          TEXT NOT NULL,
    context        TEXT NOT NULL DEFAULT '',
    options        TEXT NOT NULL DEFAULT '[]',
    status         TEXT NOT NULL DEFAULT 'open'
                   CHECK (status IN ('open', 'decided', 'rejected')),
    decided_option INTEGER,
    rationale      TEXT NOT NULL DEFAULT '',
    decided_at_ms  INTEGER,
    review_at_ms   INTEGER,
    created_at_ms  INTEGER NOT NULL,
    updated_at_ms  INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_goals_project ON goals(project_id);
CREATE INDEX IF NOT EXISTS idx_decisions_project ON decisions(project_id);
CREATE INDEX IF NOT EXISTS idx_decisions_goal ON decisions(goal_id);
