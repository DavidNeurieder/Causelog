import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/core/api/api_client.dart';
import 'package:causelog_app/core/errors/app_exception.dart';
import 'package:causelog_app/core/sync/sync_status.dart';

void main() {
  group('AppException', () {
    test('factories set expected code and status', () {
      final unauth = AppException.unauthenticated();
      expect(unauth.code, 'unauthenticated');
      expect(unauth.statusCode, 401);

      final forbidden = AppException.forbidden('Nope');
      expect(forbidden.message, 'Nope');
      expect(forbidden.code, 'forbidden');
      expect(forbidden.statusCode, 403);

      final network = AppException.network();
      expect(network.code, 'network');
      expect(network.statusCode, isNull);
    });

    test('toString includes key fields', () {
      const e = AppException('boom', code: 'x', statusCode: 500);
      expect(e.toString(), contains('boom'));
      expect(e.toString(), contains('x'));
      expect(e.toString(), contains('500'));
    });
  });

  group('ApiClient.newIdempotencyKey', () {
    test('includes prefix and separator', () {
      final key = ApiClient.newIdempotencyKey('capture');
      expect(key, startsWith('capture-'));
      expect(key.split('-').length, greaterThanOrEqualTo(3));
    });

    test('generates different keys across calls', () {
      final a = ApiClient.newIdempotencyKey('req');
      final b = ApiClient.newIdempotencyKey('req');
      expect(a, isNot(equals(b)));
    });
  });

  group('SyncStatus', () {
    test('idle constructor preserves counters and message', () {
      final now = DateTime.now();
      final status = SyncStatus.idle(
        lastSyncedAt: now,
        pendingChanges: 3,
        pendingConflicts: 1,
        message: 'Queued for sync',
      );
      expect(status.state, SyncState.idle);
      expect(status.lastSyncedAt, now);
      expect(status.pendingChanges, 3);
      expect(status.pendingConflicts, 1);
      expect(status.message, 'Queued for sync');
    });
  });
}
