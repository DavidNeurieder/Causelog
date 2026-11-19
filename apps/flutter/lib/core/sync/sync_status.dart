enum SyncState { idle, syncing, offline, error }

class SyncStatus {
  final SyncState state;
  final DateTime? lastSyncedAt;
  final int pendingChanges;
  final int pendingConflicts;
  final String? message;

  const SyncStatus({
    required this.state,
    this.lastSyncedAt,
    this.pendingChanges = 0,
    this.pendingConflicts = 0,
    this.message,
  });

  const SyncStatus.idle({
    DateTime? lastSyncedAt,
    int pendingChanges = 0,
    int pendingConflicts = 0,
  }) : this(
         state: SyncState.idle,
         lastSyncedAt: lastSyncedAt,
         pendingChanges: pendingChanges,
         pendingConflicts: pendingConflicts,
       );
}
