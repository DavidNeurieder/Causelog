import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_state.dart';
import '../core/auth/session_controller.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AuthState>((ref) {
      final api = ref.watch(apiClientProvider);
      final controller = SessionController(api);
      // bootstrap asynchronously; UI shows loading until state resolves
      Future.microtask(controller.bootstrap);
      return controller;
    });
