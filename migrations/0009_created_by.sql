-- M9: Track who created each entity.
-- Add created_by to goals, decisions, experiments, notes, and revisions.
-- Nullable for existing data (legacy items show "Unknown" in the UI).

ALTER TABLE goals ADD COLUMN created_by TEXT REFERENCES users(id);
ALTER TABLE decisions ADD COLUMN created_by TEXT REFERENCES users(id);
ALTER TABLE experiments ADD COLUMN created_by TEXT REFERENCES users(id);
ALTER TABLE notes ADD COLUMN created_by TEXT REFERENCES users(id);
ALTER TABLE revisions ADD COLUMN created_by TEXT REFERENCES users(id);
