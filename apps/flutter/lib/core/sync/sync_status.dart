enum SyncState {
  idle,
  syncing,
  offline,
  error,
}

class SyncStatus {
  final SyncState state;
  final DateTime? lastSyncedAt;
  final int pendingChanges;
  final String? message;

  const SyncStatus({
    required this.state,
    this.lastSyncedAt,
    this.pendingChanges = 0,
    this.message,
  });

  const SyncStatus.idle({DateTime? lastSyncedAt, int pendingChanges = 0})
      : this(
          state: SyncState.idle,
          lastSyncedAt: lastSyncedAt,
          pendingChanges: pendingChanges,
        );
}
