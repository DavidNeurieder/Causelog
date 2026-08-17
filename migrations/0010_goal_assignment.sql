-- M10: Goal assignment.
-- Allow assigning goals to project members.

ALTER TABLE goals ADD COLUMN assigned_to TEXT REFERENCES users(id);
