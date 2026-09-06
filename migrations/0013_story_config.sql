-- M13: Per-project story presentation config.
-- "Underlying data stays untouched": this table only holds selection,
-- ordering, and summary overrides consumed by the story page and export
-- renderers.

CREATE TABLE IF NOT EXISTS story_config (
    project_id    TEXT PRIMARY KEY NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    json          TEXT NOT NULL,
    updated_at_ms INTEGER NOT NULL
);