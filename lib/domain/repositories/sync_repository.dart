import '../models/sync_status.dart';

/// Kept as an abstraction so feature code never depends on `cloud_firestore`
/// directly — `FirebaseSyncRepository` (data/sync/firebase_sync_repository.dart)
/// is the real, wired-in implementation (see `syncRepositoryProvider` in
/// app/providers.dart). See ARCHITECTURE.md §6 "Firebase sync" for the
/// push/pull/conflict-resolution design actually in use.
abstract class SyncRepository {
  Stream<SyncStatus> watchStatus();

  Future<void> pushLocalChanges();

  Future<void> pullRemoteChanges();

  /// Convenience: push then pull.
  Future<void> syncNow();

  /// Permanently deletes every synced document under the signed-in user's
  /// `/users/{uid}/*` tree. Does **not** touch the local Drift database —
  /// this only wipes the cloud copy (see data_settings_section.dart's
  /// "Delete account & cloud data" flow, which pairs this with
  /// [AuthService.deleteAccount] for a full account wipe). Irreversible.
  Future<void> deleteAllCloudData();
}
