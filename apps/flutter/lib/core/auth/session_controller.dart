import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'auth_state.dart';

class SessionController extends StateNotifier<AuthState> {
  final ApiClient api;

  SessionController(this.api) : super(const AuthUnknown());

  Future<void> bootstrap() async {
    state = const AuthUnknown();
    final url = await AppConfig.loadServerUrl();
    if (url == null || url.isEmpty) {
      state = const AuthNeedsServer();
      return;
    }
    try {
      await api.configure(url);
      await _routeAfterConnect();
    } catch (e) {
      if (e is AppException && e.code == 'no_server') {
        state = const AuthNeedsServer();
      } else {
        state = const AuthUnauthenticated();
      }
    }
  }

  Future<void> setServer(String url) async {
    await AppConfig.saveServerUrl(url);
    await api.configure(AppConfig.normalize(url));
    api.csrfToken = null;
    await _routeAfterConnect();
  }

  Future<void> _routeAfterConnect() async {
    try {
      final setup = await api.getJson('/api/v1/setup/status');
      if (setup['setup_required'] == true) {
        state = const AuthNeedsSetup();
        return;
      }
    } catch (_) {
      // if status check fails, fall through to session/login
    }
    await refreshSession();
  }

  Future<void> clearServer() async {
    await api.clearSession();
    await AppConfig.clearServerUrl();
    state = const AuthNeedsServer();
  }

  Future<void> refreshSession() async {
    if (!api.isConfigured) {
      state = const AuthNeedsServer();
      return;
    }
    try {
      final json = await api.getJson('/api/v1/session');
      final user = ApiUser.fromJson(json['user'] as Map<String, dynamic>);
      final csrf = json['csrf_token'] as String? ?? '';
      api.csrfToken = csrf;
      if (!user.approved) {
        state = AuthUnapproved(user);
      } else {
        state = AuthAuthenticated(user: user, csrfToken: csrf);
      }
    } on AppException catch (e) {
      if (e.statusCode == 401) {
        api.csrfToken = null;
        state = const AuthUnauthenticated();
      } else if (e.code == 'no_server') {
        state = const AuthNeedsServer();
      } else {
        // Server reachable but session invalid/other issue -> treat as unauthenticated
        api.csrfToken = null;
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      api.csrfToken = null;
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    final data = await api.postJson(
      '/api/v1/auth/login',
      data: {'username': username, 'password': password},
    );
    if (data is! Map<String, dynamic>) {
      throw const AppException(
        'Invalid login response',
        code: 'invalid_response',
      );
    }
    final user = ApiUser.fromJson(data['user'] as Map<String, dynamic>);
    final csrf = data['csrf_token'] as String? ?? '';
    api.csrfToken = csrf;
    if (!user.approved) {
      state = AuthUnapproved(user);
    } else {
      state = AuthAuthenticated(user: user, csrfToken: csrf);
    }
  }

  Future<void> register(
    String username,
    String displayName,
    String password,
  ) async {
    await api.postJson(
      '/api/v1/auth/register',
      data: {
        'username': username,
        'display_name': displayName,
        'password': password,
      },
    );
  }

  Future<void> setup(
    String username,
    String displayName,
    String password,
  ) async {
    final data = await api.postJson(
      '/api/v1/setup',
      data: {
        'username': username,
        'display_name': displayName,
        'password': password,
      },
    );
    if (data is Map<String, dynamic>) {
      final user = ApiUser.fromJson(data['user'] as Map<String, dynamic>);
      final csrf = data['csrf_token'] as String? ?? '';
      api.csrfToken = csrf;
      state = AuthAuthenticated(user: user, csrfToken: csrf);
    } else {
      await refreshSession();
    }
  }

  Future<void> logout() async {
    try {
      await api.postJson('/api/v1/auth/logout', data: {});
    } catch (_) {
      // ignore; clear local state anyway
    }
    await api.clearSession();
    state = const AuthUnauthenticated();
  }
}
