-- M8: multi-user support.
-- Add role and approval to users, project membership, and created_by to projects.

-- User role and approval status.
ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'
    CHECK (role IN ('admin', 'user'));
ALTER TABLE users ADD COLUMN approved INTEGER NOT NULL DEFAULT 0;

-- Project membership with role (owner can manage members, member can read/write).
CREATE TABLE IF NOT EXISTS project_members (
    project_id    TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id       TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role          TEXT NOT NULL DEFAULT 'member'
                  CHECK (role IN ('owner', 'member')),
    created_at_ms INTEGER NOT NULL,
    PRIMARY KEY (project_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_pm_user ON project_members(user_id);

-- Track who created a project.
ALTER TABLE projects ADD COLUMN created_by TEXT REFERENCES users(id);
