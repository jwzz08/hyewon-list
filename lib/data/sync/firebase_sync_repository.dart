import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/calendar_event.dart';
import '../../domain/models/category.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/models/tag.dart';
import '../../domain/models/task.dart';
import '../../domain/models/theme_preset.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/repositories/calendar_event_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/theme_preset_repository.dart';

/// Real Firestore-backed [SyncRepository] — see ARCHITECTURE.md "Firebase
/// sync TODOs" for the original design; this follows it directly:
///
///  - Data lives under `/users/{uid}/{collection}/{id}`, one collection per
///    syncable model (tasks, calendarEvents, categories, tags, themePresets,
///    settings). [WidgetPreference] is device-local and deliberately never
///    touched here.
///  - Every document is just `model.toJson()` / `Model.fromJson(...)` — the
///    same JSON shape already used by [ImportExportService], so there's one
///    source of truth for "what a Task looks like serialized", not two.
///  - Conflict resolution is last-write-wins by `updatedAt`, compared
///    per-record on *both* [pushLocalChanges] and [pullRemoteChanges] (no
///    dirty-flag/revision tracking — acceptable for a single-user personal
///    planner; revisit if concurrent multi-device editing of the *same*
///    record becomes common). This symmetry is what makes signing into an
///    existing account from a second device (see AuthService.signIn) a safe
///    merge rather than a coin-flip: this device's local-only records (ids
///    the target account's Firestore has never seen) get added untouched on
///    push, records that already exist remotely only get overwritten if
///    this device's copy is actually newer, and pullRemoteChanges brings
///    everything else down the same way — nothing gets silently clobbered
///    in either direction.
///  - Auth defaults to anonymous ([FirebaseAuth.signInAnonymously]), just
///    enough to scope data per-install offline. See data/sync/auth_service.dart
///    for turning that into a real email/password account the same
///    Firestore documents (unchanged shape) sync through — either way,
///    `_ensureUserId` below just reads whatever `FirebaseAuth.currentUser`
///    already is.
///  - Every public method fails soft: if Firebase wasn't initialized (see
///    `main.dart`) or the network/auth call fails, methods emit
///    [SyncState.offline]/[SyncState.error] via [watchStatus] rather than
///    throwing into UI code that isn't expecting it — the one exception is
///    that [pushLocalChanges]/[pullRemoteChanges] *do* rethrow after
///    emitting the error status, so a caller that explicitly awaits one of
///    them (e.g. a "Sync now" button) can still show its own error UI.
class FirebaseSyncRepository implements SyncRepository {
  FirebaseSyncRepository({
    required this.taskRepository,
    required this.calendarEventRepository,
    required this.categoryRepository,
    required this.tagRepository,
    required this.appSettingsRepository,
    required this.themePresetRepository,
  });

  final TaskRepository taskRepository;
  final CalendarEventRepository calendarEventRepository;
  final CategoryRepository categoryRepository;
  final TagRepository tagRepository;
  final AppSettingsRepository appSettingsRepository;
  final ThemePresetRepository themePresetRepository;

  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = SyncStatus.initial;

  void _emit(SyncStatus status) {
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  @override
  Stream<SyncStatus> watchStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }

  /// Returns the signed-in user's uid, signing in anonymously on first use.
  /// Returns null (never throws) if Firebase isn't initialized or the
  /// sign-in call fails — callers treat that as "sync unavailable".
  Future<String?> _ensureUserId() async {
    if (Firebase.apps.isEmpty) return null;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
      return user?.uid;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid, String name) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection(name);

  @override
  Future<void> pushLocalChanges() async {
    final String? uid = await _ensureUserId();
    if (uid == null) {
      _emit(const SyncStatus(state: SyncState.offline));
      return;
    }
    _emit(const SyncStatus(state: SyncState.syncing));
    try {
      await _pushTasks(uid);
      await _pushEvents(uid);
      await _pushCategories(uid);
      await _pushTags(uid);
      await _pushThemePresets(uid);
      await _pushSettings(uid);
      _emit(SyncStatus(state: SyncState.success, lastSyncedAt: DateTime.now()));
    } catch (e) {
      _emit(SyncStatus(state: SyncState.error, errorMessage: e.toString()));
      rethrow;
    }
  }

  // Each _push* below reads the remote collection first so it can skip (or
  // rather, not overwrite) any record where the remote copy is newer —
  // mirrors the corresponding _pull* method's comparison exactly, just in
  // the opposite direction. This extra read per collection is what upgrades
  // pushLocalChanges from a blind overwrite into a real last-write-wins
  // participant; see the class doc for why that matters for account merges.

  Future<void> _pushTasks(String uid) async {
    final List<Task> local = await taskRepository.watchAll().first;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'tasks').get();
    final Map<String, Task> remoteById = {
      for (final doc in snapshot.docs) doc.id: Task.fromJson(doc.data()),
    };
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final Task t in local) {
      final Task? remote = remoteById[t.id];
      if (remote == null || t.updatedAt.isAfter(remote.updatedAt)) {
        batch.set(_collection(uid, 'tasks').doc(t.id), t.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> _pushEvents(String uid) async {
    final List<CalendarEvent> local = await calendarEventRepository.watchAll().first;
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _collection(uid, 'calendarEvents').get();
    final Map<String, CalendarEvent> remoteById = {
      for (final doc in snapshot.docs) doc.id: CalendarEvent.fromJson(doc.data()),
    };
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final CalendarEvent e in local) {
      final CalendarEvent? remote = remoteById[e.id];
      if (remote == null || e.updatedAt.isAfter(remote.updatedAt)) {
        batch.set(_collection(uid, 'calendarEvents').doc(e.id), e.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> _pushCategories(String uid) async {
    final List<Category> local = await categoryRepository.watchAll().first;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'categories').get();
    final Map<String, Category> remoteById = {
      for (final doc in snapshot.docs) doc.id: Category.fromJson(doc.data()),
    };
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final Category c in local) {
      final Category? remote = remoteById[c.id];
      if (remote == null || c.updatedAt.isAfter(remote.updatedAt)) {
        batch.set(_collection(uid, 'categories').doc(c.id), c.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> _pushTags(String uid) async {
    final List<Tag> local = await tagRepository.watchAll().first;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'tags').get();
    final Map<String, Tag> remoteById = {
      for (final doc in snapshot.docs) doc.id: Tag.fromJson(doc.data()),
    };
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final Tag tg in local) {
      final Tag? remote = remoteById[tg.id];
      if (remote == null || tg.updatedAt.isAfter(remote.updatedAt)) {
        batch.set(_collection(uid, 'tags').doc(tg.id), tg.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> _pushThemePresets(String uid) async {
    final List<ThemePreset> local = await themePresetRepository.watchAll().first;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'themePresets').get();
    final Map<String, ThemePreset> remoteById = {
      for (final doc in snapshot.docs) doc.id: ThemePreset.fromJson(doc.data()),
    };
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final ThemePreset p in local) {
      final ThemePreset? remote = remoteById[p.id];
      if (remote == null || p.updatedAt.isAfter(remote.updatedAt)) {
        batch.set(_collection(uid, 'themePresets').doc(p.id), p.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> _pushSettings(String uid) async {
    final AppSettings local = await appSettingsRepository.get();
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _collection(uid, 'settings').doc('appSettings').get();
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      final AppSettings remote = AppSettings.fromJson(data);
      if (!local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _collection(uid, 'settings').doc('appSettings').set(local.toJson());
  }

  @override
  Future<void> pullRemoteChanges() async {
    final String? uid = await _ensureUserId();
    if (uid == null) {
      _emit(const SyncStatus(state: SyncState.offline));
      return;
    }
    _emit(const SyncStatus(state: SyncState.syncing));
    try {
      await _pullTasks(uid);
      await _pullEvents(uid);
      await _pullCategories(uid);
      await _pullTags(uid);
      await _pullThemePresets(uid);
      await _pullSettings(uid);
      _emit(SyncStatus(state: SyncState.success, lastSyncedAt: DateTime.now()));
    } catch (e) {
      _emit(SyncStatus(state: SyncState.error, errorMessage: e.toString()));
      rethrow;
    }
  }

  Future<void> _pullTasks(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'tasks').get();
    final Map<String, Task> localById = {
      for (final Task t in await taskRepository.watchAll().first) t.id: t,
    };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Task remote = Task.fromJson(doc.data());
      final Task? existing = localById[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        await taskRepository.create(remote); // create() upserts by id
      }
    }
  }

  Future<void> _pullEvents(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _collection(uid, 'calendarEvents').get();
    final Map<String, CalendarEvent> localById = {
      for (final CalendarEvent e in await calendarEventRepository.watchAll().first) e.id: e,
    };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final CalendarEvent remote = CalendarEvent.fromJson(doc.data());
      final CalendarEvent? existing = localById[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        await calendarEventRepository.create(remote);
      }
    }
  }

  Future<void> _pullCategories(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'categories').get();
    final Map<String, Category> localById = {
      for (final Category c in await categoryRepository.watchAll().first) c.id: c,
    };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Category remote = Category.fromJson(doc.data());
      final Category? existing = localById[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        await categoryRepository.create(remote);
      }
    }
  }

  Future<void> _pullTags(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'tags').get();
    final Map<String, Tag> localById = {
      for (final Tag t in await tagRepository.watchAll().first) t.id: t,
    };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Tag remote = Tag.fromJson(doc.data());
      final Tag? existing = localById[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        await tagRepository.upsert(remote);
      }
    }
  }

  Future<void> _pullThemePresets(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(uid, 'themePresets').get();
    final Map<String, ThemePreset> localById = {
      for (final ThemePreset p in await themePresetRepository.watchAll().first) p.id: p,
    };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final ThemePreset remote = ThemePreset.fromJson(doc.data());
      final ThemePreset? existing = localById[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        await themePresetRepository.create(remote); // create() upserts by id
      }
    }
  }

  Future<void> _pullSettings(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _collection(uid, 'settings').doc('appSettings').get();
    final Map<String, dynamic>? data = doc.data();
    if (data == null) return;
    final AppSettings remote = AppSettings.fromJson(data);
    final AppSettings local = await appSettingsRepository.get();
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      await appSettingsRepository.save(remote);
    }
  }

  @override
  Future<void> syncNow() async {
    try {
      await pushLocalChanges();
      await pullRemoteChanges();
    } catch (_) {
      // Already reported via watchStatus by push/pull — swallow here so
      // callers that fire-and-forget syncNow() (e.g. an optimistic sync on
      // app startup) never crash on a network hiccup.
    }
  }

  @override
  Future<void> deleteAllCloudData() async {
    final String? uid = await _ensureUserId();
    if (uid == null) return; // nothing signed in / offline — nothing to delete
    for (final String collectionName in const [
      'tasks',
      'calendarEvents',
      'categories',
      'tags',
      'themePresets',
      'settings',
    ]) {
      await _deleteAllDocsIn(uid, collectionName);
    }
  }

  /// Deletes every document in `/users/{uid}/{name}`, chunked at Firestore's
  /// 500-write batch cap. A personal planner's collections will essentially
  /// never exceed that in one go, but looping rather than assuming it never
  /// will costs nothing and avoids a silently-incomplete deletion if it ever
  /// does.
  Future<void> _deleteAllDocsIn(String uid, String name) async {
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _collection(uid, name).limit(500).get();
      if (snapshot.docs.isEmpty) return;
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < 500) return;
    }
  }

  void dispose() {
    _statusController.close();
  }
}
