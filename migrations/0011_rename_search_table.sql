-- M11: Rename kaizen_search → causelog_search (brand rename).
-- FTS5 virtual tables cannot be altered, so we recreate with the new name,
-- copy data, replace triggers, and drop the old table.

-- 1. Create new FTS5 table
CREATE VIRTUAL TABLE IF NOT EXISTS causelog_search USING fts5(
    entity_type UNINDEXED,
    entity_id   UNINDEXED,
    project_id  UNINDEXED,
    title,
    body
);

-- 2. Copy existing data
INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
SELECT entity_type, entity_id, project_id, title, body FROM kaizen_search;

-- 3. Drop old triggers
DROP TRIGGER IF EXISTS trg_projects_ai;
DROP TRIGGER IF EXISTS trg_projects_au;
DROP TRIGGER IF EXISTS trg_projects_ad;
DROP TRIGGER IF EXISTS trg_goals_ai;
DROP TRIGGER IF EXISTS trg_goals_au;
DROP TRIGGER IF EXISTS trg_goals_ad;
DROP TRIGGER IF EXISTS trg_decisions_ai;
DROP TRIGGER IF EXISTS trg_decisions_au;
DROP TRIGGER IF EXISTS trg_decisions_ad;
DROP TRIGGER IF EXISTS trg_experiments_ai;
DROP TRIGGER IF EXISTS trg_experiments_au;
DROP TRIGGER IF EXISTS trg_experiments_ad;
DROP TRIGGER IF EXISTS trg_notes_ai;
DROP TRIGGER IF EXISTS trg_notes_au;
DROP TRIGGER IF EXISTS trg_notes_ad;

-- 4. Create new triggers referencing causelog_search
CREATE TRIGGER trg_projects_ai AFTER INSERT ON projects BEGIN
  INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
  VALUES ('project', new.id, new.id, new.title, new.summary);
END;
CREATE TRIGGER trg_projects_au AFTER UPDATE ON projects BEGIN
  UPDATE causelog_search SET title = new.title, body = new.summary
  WHERE entity_type = 'project' AND entity_id = old.id;
END;
CREATE TRIGGER trg_projects_ad AFTER DELETE ON projects BEGIN
  DELETE FROM causelog_search WHERE entity_type = 'project' AND entity_id = old.id;
END;

CREATE TRIGGER trg_goals_ai AFTER INSERT ON goals BEGIN
  INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
  VALUES ('goal', new.id, new.project_id, new.title, new.body);
END;
CREATE TRIGGER trg_goals_au AFTER UPDATE ON goals BEGIN
  UPDATE causelog_search SET title = new.title, body = new.body
  WHERE entity_type = 'goal' AND entity_id = old.id;
END;
CREATE TRIGGER trg_goals_ad AFTER DELETE ON goals BEGIN
  DELETE FROM causelog_search WHERE entity_type = 'goal' AND entity_id = old.id;
END;

CREATE TRIGGER trg_decisions_ai AFTER INSERT ON decisions BEGIN
  INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
  VALUES ('decision', new.id, new.project_id, new.title, new.context);
END;
CREATE TRIGGER trg_decisions_au AFTER UPDATE ON decisions BEGIN
  UPDATE causelog_search SET title = new.title, body = new.context
  WHERE entity_type = 'decision' AND entity_id = old.id;
END;
CREATE TRIGGER trg_decisions_ad AFTER DELETE ON decisions BEGIN
  DELETE FROM causelog_search WHERE entity_type = 'decision' AND entity_id = old.id;
END;

CREATE TRIGGER trg_experiments_ai AFTER INSERT ON experiments BEGIN
  INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
  VALUES ('experiment', new.id, new.project_id, new.title,
          new.hypothesis || ' ' || new.result || ' ' || new.lesson);
END;
CREATE TRIGGER trg_experiments_au AFTER UPDATE ON experiments BEGIN
  UPDATE causelog_search SET title = new.title,
      body = new.hypothesis || ' ' || new.result || ' ' || new.lesson
  WHERE entity_type = 'experiment' AND entity_id = old.id;
END;
CREATE TRIGGER trg_experiments_ad AFTER DELETE ON experiments BEGIN
  DELETE FROM causelog_search WHERE entity_type = 'experiment' AND entity_id = old.id;
END;

CREATE TRIGGER trg_notes_ai AFTER INSERT ON notes BEGIN
  INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
  VALUES ('note', new.id, new.project_id, new.title, new.body);
END;
CREATE TRIGGER trg_notes_au AFTER UPDATE ON notes BEGIN
  UPDATE causelog_search SET title = new.title, body = new.body
  WHERE entity_type = 'note' AND entity_id = old.id;
END;
CREATE TRIGGER trg_notes_ad AFTER DELETE ON notes BEGIN
  DELETE FROM causelog_search WHERE entity_type = 'note' AND entity_id = old.id;
END;

-- 5. Drop old table
DROP TABLE kaizen_search;
