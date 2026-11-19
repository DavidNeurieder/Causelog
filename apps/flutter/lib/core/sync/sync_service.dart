import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../errors/app_exception.dart';
import '../storage/local_database.dart';
import 'sync_status.dart';

class SyncController extends StateNotifier<SyncStatus> {
  final ApiClient api;
  final LocalDatabase database;

  SyncController(this.api, this.database) : super(const SyncStatus.idle());

  Future<void> initialize() async {
    try {
      await database.initialize();
      state = SyncStatus.idle(
        pendingChanges: database.pendingCount(),
        pendingConflicts: database.conflicts().length,
      );
    } catch (_) {
      state = const SyncStatus.idle();
    }
  }

  Future<void> enqueueCapture({
    required String projectId,
    required String kind,
    required String title,
    required String body,
    String? experimentId,
    required String idempotencyKey,
  }) async {
    await database.initialize();
    database.enqueue(
      kind: 'capture',
      payload: jsonEncode({
        'project_id': projectId,
        'kind': kind,
        'title': title,
        'body': body,
        'experiment_id': experimentId,
        'csrf_token': api.csrfToken,
      }),
      idempotencyKey: idempotencyKey,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    state = SyncStatus.idle(
      pendingChanges: database.pendingCount(),
      pendingConflicts: database.conflicts().length,
      message: 'Queued for sync',
    );
  }

  Future<void> syncNow() async {
    await database.initialize();
    state = SyncStatus(
      state: SyncState.syncing,
      pendingChanges: database.pendingCount(),
    );
    final entries = database.pendingEntries();
    for (final entry in entries) {
      final id = entry['id'] as int;
      try {
        final payload =
            jsonDecode(entry['payload'] as String) as Map<String, dynamic>;
        await api.postJson(
          '/api/v1/capture',
          idempotencyKey: entry['idempotency_key'] as String,
          data: payload,
        );
        database.remove(id);
      } catch (e) {
        if (e is AppException && e.statusCode == 409) {
          database.recordConflict(
            kind: entry['kind'] as String,
            payload: entry['payload'] as String,
            message: e.message,
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          );
          database.remove(id);
          state = SyncStatus(
            state: SyncState.error,
            pendingChanges: database.pendingCount(),
            pendingConflicts: database.conflicts().length,
            message: 'Conflict requires resolution: ${e.message}',
          );
          return;
        }
        database.markFailure(id, e.toString());
        state = SyncStatus(
          state: SyncState.error,
          pendingChanges: database.pendingCount(),
          pendingConflicts: database.conflicts().length,
          message: e is Exception ? e.toString() : 'Sync failed',
        );
        return;
      }
    }
    try {
      final projectsJson = await api.getJson('/api/v1/projects');
      final items = (projectsJson['items'] as List?) ?? const [];
      database.cacheProjects(items.whereType<Map<String, dynamic>>().toList());
    } catch (_) {
      // Keep offline cache best-effort.
    }
    state = SyncStatus.idle(
      lastSyncedAt: DateTime.now(),
      pendingChanges: database.pendingCount(),
      pendingConflicts: database.conflicts().length,
    );
  }

  List<Map<String, Object?>> get conflicts => database.conflicts();

  List<Map<String, dynamic>> get cachedProjects => database.cachedProjects();

  void resolveConflict(int id) {
    database.resolveConflict(id);
    state = SyncStatus.idle(
      lastSyncedAt: state.lastSyncedAt,
      pendingChanges: database.pendingCount(),
      pendingConflicts: database.conflicts().length,
      message: 'Conflict resolved',
    );
  }

  @override
  void dispose() {
    database.dispose();
    super.dispose();
  }
}
