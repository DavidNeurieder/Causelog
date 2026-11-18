import 'sync_status.dart';

/// M7 foundation: synchronization service skeleton.
///
/// Planned responsibilities:
/// - maintain a local Drift/SQLite cache of entities
/// - queue pending writes in an outbox
/// - sync with server using idempotency keys
/// - detect conflicts (409/current-state) and surface resolution UI
/// - never silently overwrite remote revisions
class SyncService {
  // ignore: prefer_final_fields
  SyncStatus _status = const SyncStatus.idle();

  SyncStatus get status => _status;

  Future<void> initialize() async {
    // TODO(M7): open local database, restore outbox state
  }

  Future<void> syncNow() async {
    // TODO(M7): push outbox, pull changes, resolve conflicts
  }

  Future<void> dispose() async {}
}
