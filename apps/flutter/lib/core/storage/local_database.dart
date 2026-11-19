import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class LocalDatabase {
  Database? _db;

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('LocalDatabase has not been initialized');
    }
    return database;
  }

  Future<void> initialize() async {
    if (_db != null) return;
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'causelog_local.sqlite'));
    _db = sqlite3.open(file.path);
    _ensureSchema();
  }

  void openInMemoryForTest() {
    _db?.dispose();
    _db = sqlite3.openInMemory();
    _ensureSchema();
  }

  void _ensureSchema() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL,
        payload TEXT NOT NULL,
        idempotency_key TEXT NOT NULL UNIQUE,
        created_at_ms INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS conflicts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL,
        payload TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at_ms INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS cache_projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT,
        status TEXT,
        updated_at_ms INTEGER NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
  }

  int pendingCount() {
    final result = db.select('SELECT COUNT(*) AS c FROM outbox');
    return result.first['c'] as int;
  }

  List<Map<String, Object?>> pendingEntries() {
    final result = db.select(
      'SELECT id, kind, payload, idempotency_key, created_at_ms, attempts, last_error '
      'FROM outbox ORDER BY id ASC',
    );
    return result.map((row) => row).toList();
  }

  void enqueue({
    required String kind,
    required String payload,
    required String idempotencyKey,
    required int createdAtMs,
  }) {
    db.execute(
      'INSERT OR IGNORE INTO outbox '
      '(kind, payload, idempotency_key, created_at_ms) VALUES (?, ?, ?, ?)',
      [kind, payload, idempotencyKey, createdAtMs],
    );
  }

  void remove(int id) {
    db.execute('DELETE FROM outbox WHERE id = ?', [id]);
  }

  void markFailure(int id, String error) {
    db.execute(
      'UPDATE outbox SET attempts = attempts + 1, last_error = ? WHERE id = ?',
      [error, id],
    );
  }

  void recordConflict({
    required String kind,
    required String payload,
    required String message,
    required int createdAtMs,
  }) {
    db.execute(
      'INSERT INTO conflicts (kind, payload, message, created_at_ms) VALUES (?, ?, ?, ?)',
      [kind, payload, message, createdAtMs],
    );
  }

  List<Map<String, Object?>> conflicts() {
    final result = db.select(
      'SELECT id, kind, payload, message, created_at_ms FROM conflicts ORDER BY id ASC',
    );
    return result.map((row) => row).toList();
  }

  void resolveConflict(int id) {
    db.execute('DELETE FROM conflicts WHERE id = ?', [id]);
  }

  void cacheProjects(List<Map<String, dynamic>> projects) {
    db.execute('DELETE FROM cache_projects');
    for (final project in projects) {
      db.execute(
        'INSERT OR REPLACE INTO cache_projects (id, title, summary, status, updated_at_ms, payload) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          project['id'],
          project['title'] ?? '',
          project['summary'],
          project['status'],
          project['updated_at_ms'] ?? 0,
          jsonEncode(project),
        ],
      );
    }
  }

  List<Map<String, dynamic>> cachedProjects() {
    final database = _db;
    if (database == null) return const [];
    final result = database.select(
      'SELECT payload FROM cache_projects ORDER BY updated_at_ms DESC',
    );
    return result
        .map(
          (row) => jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        )
        .toList();
  }

  void dispose() {
    _db?.dispose();
    _db = null;
  }
}
