import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/core/storage/local_database.dart';

void main() {
  group('LocalDatabase', () {
    late LocalDatabase db;

    setUp(() {
      db = LocalDatabase()..openInMemoryForTest();
    });

    tearDown(() {
      db.dispose();
    });

    test('enqueues and counts pending outbox entries', () {
      expect(db.pendingCount(), 0);
      db.enqueue(
        kind: 'capture',
        payload: jsonEncode({'title': 't'}),
        idempotencyKey: 'k1',
        createdAtMs: 1,
      );
      db.enqueue(
        kind: 'capture',
        payload: jsonEncode({'title': 't2'}),
        idempotencyKey: 'k2',
        createdAtMs: 2,
      );
      // duplicate idempotency key should be ignored
      db.enqueue(
        kind: 'capture',
        payload: jsonEncode({'title': 'dup'}),
        idempotencyKey: 'k1',
        createdAtMs: 3,
      );

      expect(db.pendingCount(), 2);
      final entries = db.pendingEntries();
      expect(entries.length, 2);
      expect(entries.first['idempotency_key'], 'k1');
    });

    test('remove and markFailure update outbox state', () {
      db.enqueue(
        kind: 'capture',
        payload: '{}',
        idempotencyKey: 'k1',
        createdAtMs: 1,
      );
      final id = db.pendingEntries().single['id'] as int;
      db.markFailure(id, 'boom');
      final afterFail = db.pendingEntries().single;
      expect(afterFail['attempts'], 1);
      expect(afterFail['last_error'], 'boom');

      db.remove(id);
      expect(db.pendingCount(), 0);
    });

    test('records and resolves conflicts', () {
      db.recordConflict(
        kind: 'capture',
        payload: '{"x":1}',
        message: 'conflict',
        createdAtMs: 10,
      );
      final conflicts = db.conflicts();
      expect(conflicts, hasLength(1));
      expect(conflicts.single['message'], 'conflict');

      db.resolveConflict(conflicts.single['id'] as int);
      expect(db.conflicts(), isEmpty);
    });

    test('caches projects and returns latest payloads', () {
      db.cacheProjects([
        {
          'id': 'p1',
          'title': 'Project 1',
          'summary': 's1',
          'status': 'active',
          'updated_at_ms': 100,
        },
        {
          'id': 'p2',
          'title': 'Project 2',
          'summary': null,
          'status': 'paused',
          'updated_at_ms': 200,
        },
      ]);

      final cached = db.cachedProjects();
      expect(cached, hasLength(2));
      expect(cached.first['id'], 'p2'); // ordered by updated_at_ms desc
      expect(cached.last['title'], 'Project 1');

      db.cacheProjects([
        {
          'id': 'p3',
          'title': 'Only',
          'status': 'active',
          'updated_at_ms': 300,
        },
      ]);
      expect(db.cachedProjects().map((e) => e['id']), ['p3']);
    });
  });
}
