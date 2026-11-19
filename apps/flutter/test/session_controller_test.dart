import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/core/api/api_client.dart';
import 'package:causelog_app/core/auth/auth_state.dart';
import 'package:causelog_app/core/auth/session_controller.dart';
import 'package:causelog_app/core/errors/app_exception.dart';

class FakeApiClient extends ApiClient {
  bool configured = true;
  final Future<Map<String, dynamic>> Function(
    String path, {
    Map<String, dynamic>? query,
  })?
  getJsonHandler;
  final Future<dynamic> Function(
    String path, {
    Object? data,
    String? idempotencyKey,
  })?
  postJsonHandler;

  FakeApiClient({this.getJsonHandler, this.postJsonHandler});

  @override
  bool get isConfigured => configured;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final handler = getJsonHandler;
    if (handler != null) return handler(path, query: query);
    throw UnimplementedError('getJson $path');
  }

  @override
  Future<dynamic> postJson(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async {
    final handler = postJsonHandler;
    if (handler != null) {
      return handler(path, data: data, idempotencyKey: idempotencyKey);
    }
    throw UnimplementedError('postJson $path');
  }

  @override
  Future<void> clearSession() async {
    csrfToken = null;
  }
}

void main() {
  group('SessionController', () {
    test('refreshSession sets Authenticated for approved user', () async {
      final api = FakeApiClient(
        getJsonHandler: (path, {query}) async {
          expect(path, '/api/v1/session');
          return {
            'csrf_token': 'csrf-123',
            'user': {
              'id': 'u1',
              'username': 'alice',
              'display_name': 'Alice',
              'role': 'admin',
              'approved': true,
              'created_at_ms': 1,
            },
          };
        },
      );
      final controller = SessionController(api);
      await controller.refreshSession();

      expect(controller.state, isA<AuthAuthenticated>());
      final state = controller.state as AuthAuthenticated;
      expect(state.user.username, 'alice');
      expect(state.csrfToken, 'csrf-123');
      expect(api.csrfToken, 'csrf-123');
    });

    test('refreshSession sets AuthUnapproved for pending user', () async {
      final api = FakeApiClient(
        getJsonHandler: (path, {query}) async => {
          'csrf_token': 'csrf-456',
          'user': {
            'id': 'u2',
            'username': 'bob',
            'display_name': 'Bob',
            'role': 'user',
            'approved': false,
            'created_at_ms': 1,
          },
        },
      );
      final controller = SessionController(api);
      await controller.refreshSession();

      expect(controller.state, isA<AuthUnapproved>());
      expect((controller.state as AuthUnapproved).user.username, 'bob');
      expect(api.csrfToken, 'csrf-456');
    });

    test('refreshSession treats 401 as unauthenticated', () async {
      final api = FakeApiClient(
        getJsonHandler: (path, {query}) async {
          throw const AppException('Unauthenticated', statusCode: 401);
        },
      )..csrfToken = 'stale';
      final controller = SessionController(api);
      await controller.refreshSession();

      expect(controller.state, isA<AuthUnauthenticated>());
      expect(api.csrfToken, isNull);
    });

    test('refreshSession sets AuthNeedsServer when not configured', () async {
      final api = FakeApiClient()..configured = false;
      final controller = SessionController(api);
      await controller.refreshSession();

      expect(controller.state, isA<AuthNeedsServer>());
    });

    test('logout posts then clears session locally', () async {
      var posted = false;
      final api = FakeApiClient(
        postJsonHandler: (path, {data, idempotencyKey}) async {
          expect(path, '/api/v1/auth/logout');
          posted = true;
          return {};
        },
      )..csrfToken = 'csrf';
      final controller = SessionController(api);
      await controller.logout();

      expect(posted, isTrue);
      expect(controller.state, isA<AuthUnauthenticated>());
      expect(api.csrfToken, isNull);
    });
  });
}
