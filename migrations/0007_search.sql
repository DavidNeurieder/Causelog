-- M7: full-text search. An FTS5 index over every searchable entity, kept in
-- sync by triggers (the virtual table has to live alongside the triggers, and
-- backfill covers anything written before this migration).
-- entity_type: 'project' | 'goal' | 'decision' | 'experiment' | 'note'

CREATE VIRTUAL TABLE IF NOT EXISTS kaizen_search USING fts5(
    entity_type UNINDEXED,
    entity_id   UNINDEXED,
    project_id  UNINDEXED,
    title,
    body
);

-- projects
CREATE TRIGGER IF NOT EXISTS trg_projects_ai AFTER INSERT ON projects BEGIN
  INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
  VALUES ('project', new.id, new.id, new.title, new.summary);
END;
CREATE TRIGGER IF NOT EXISTS trg_projects_au AFTER UPDATE ON projects BEGIN
  UPDATE kaizen_search SET title = new.title, body = new.summary
  WHERE entity_type = 'project' AND entity_id = old.id;
END;
CREATE TRIGGER IF NOT EXISTS trg_projects_ad AFTER DELETE ON projects BEGIN
  DELETE FROM kaizen_search WHERE entity_type = 'project' AND entity_id = old.id;
END;

-- goals
CREATE TRIGGER IF NOT EXISTS trg_goals_ai AFTER INSERT ON goals BEGIN
  INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
  VALUES ('goal', new.id, new.project_id, new.title, new.body);
END;
CREATE TRIGGER IF NOT EXISTS trg_goals_au AFTER UPDATE ON goals BEGIN
  UPDATE kaizen_search SET title = new.title, body = new.body
  WHERE entity_type = 'goal' AND entity_id = old.id;
END;
CREATE TRIGGER IF NOT EXISTS trg_goals_ad AFTER DELETE ON goals BEGIN
  DELETE FROM kaizen_search WHERE entity_type = 'goal' AND entity_id = old.id;
END;

-- decisions (body covers the context; option text lives in JSON and is not
-- indexed — title + context carry most of the signal)
CREATE TRIGGER IF NOT EXISTS trg_decisions_ai AFTER INSERT ON decisions BEGIN
  INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
  VALUES ('decision', new.id, new.project_id, new.title, new.context);
END;
CREATE TRIGGER IF NOT EXISTS trg_decisions_au AFTER UPDATE ON decisions BEGIN
  UPDATE kaizen_search SET title = new.title, body = new.context
  WHERE entity_type = 'decision' AND entity_id = old.id;
END;
CREATE TRIGGER IF NOT EXISTS trg_decisions_ad AFTER DELETE ON decisions BEGIN
  DELETE FROM kaizen_search WHERE entity_type = 'decision' AND entity_id = old.id;
END;

-- experiments
CREATE TRIGGER IF NOT EXISTS trg_experiments_ai AFTER INSERT ON experiments BEGIN
  INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
  VALUES ('experiment', new.id, new.project_id, new.title,
          new.hypothesis || ' ' || new.result || ' ' || new.lesson);
END;
CREATE TRIGGER IF NOT EXISTS trg_experiments_au AFTER UPDATE ON experiments BEGIN
  UPDATE kaizen_search SET title = new.title,
      body = new.hypothesis || ' ' || new.result || ' ' || new.lesson
  WHERE entity_type = 'experiment' AND entity_id = old.id;
END;
CREATE TRIGGER IF NOT EXISTS trg_experiments_ad AFTER DELETE ON experiments BEGIN
  DELETE FROM kaizen_search WHERE entity_type = 'experiment' AND entity_id = old.id;
END;

-- notes
CREATE TRIGGER IF NOT EXISTS trg_notes_ai AFTER INSERT ON notes BEGIN
  INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
  VALUES ('note', new.id, new.project_id, new.title, new.body);
END;
CREATE TRIGGER IF NOT EXISTS trg_notes_au AFTER UPDATE ON notes BEGIN
  UPDATE kaizen_search SET title = new.title, body = new.body
  WHERE entity_type = 'note' AND entity_id = old.id;
END;
CREATE TRIGGER IF NOT EXISTS trg_notes_ad AFTER DELETE ON notes BEGIN
  DELETE FROM kaizen_search WHERE entity_type = 'note' AND entity_id = old.id;
END;

-- backfill anything created before this migration ran
INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
SELECT 'project', id, id, title, summary FROM projects;
INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
SELECT 'goal', id, project_id, title, body FROM goals;
INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
SELECT 'decision', id, project_id, title, context FROM decisions;
INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
SELECT 'experiment', id, project_id, title, hypothesis || ' ' || result || ' ' || lesson
FROM experiments;
INSERT INTO kaizen_search(entity_type, entity_id, project_id, title, body)
SELECT 'note', id, project_id, title, body FROM notes;
