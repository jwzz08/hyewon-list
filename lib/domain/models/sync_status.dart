/// Placeholder model for the future Firebase sync layer. Not persisted or
/// used anywhere yet — exists so [SyncRepository] has a concrete return type
/// to design against. See ARCHITECTURE.md "Firebase sync TODOs".
enum SyncState { idle, syncing, success, error, offline }

class SyncStatus {
  const SyncStatus({
    required this.state,
    this.lastSyncedAt,
    this.pendingChangeCount = 0,
    this.errorMessage,
  });

  final SyncState state;
  final DateTime? lastSyncedAt;
  final int pendingChangeCount;
  final String? errorMessage;

  static const SyncStatus initial = SyncStatus(state: SyncState.offline);
}
