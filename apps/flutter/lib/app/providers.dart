import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_state.dart';
import '../core/auth/session_controller.dart';
import '../core/storage/local_database.dart';
import '../core/sync/sync_service.dart';
import '../core/sync/sync_status.dart';

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

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncStatus>((ref) {
      final api = ref.watch(apiClientProvider);
      final db = ref.watch(localDatabaseProvider);
      final controller = SyncController(api, db);
      Future.microtask(controller.initialize);
      return controller;
    });
