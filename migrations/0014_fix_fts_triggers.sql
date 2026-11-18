-- M14: Recreate FTS triggers for goals and experiments dropped by migration 0012
-- (table recreation removes triggers) and rebuild their search index entries.

DROP TRIGGER IF EXISTS trg_goals_ai;
DROP TRIGGER IF EXISTS trg_goals_au;
DROP TRIGGER IF EXISTS trg_goals_ad;
DROP TRIGGER IF EXISTS trg_experiments_ai;
DROP TRIGGER IF EXISTS trg_experiments_au;
DROP TRIGGER IF EXISTS trg_experiments_ad;

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

-- Rebuild index entries for goals and experiments to repair any drift.
DELETE FROM causelog_search WHERE entity_type IN ('goal', 'experiment');
INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
SELECT 'goal', id, project_id, title, body FROM goals;
INSERT INTO causelog_search(entity_type, entity_id, project_id, title, body)
SELECT 'experiment', id, project_id, title, hypothesis || ' ' || result || ' ' || lesson
FROM experiments;
