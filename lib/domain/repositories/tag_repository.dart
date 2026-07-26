import '../models/tag.dart';

abstract class TagRepository {
  Stream<List<Tag>> watchAll();
  Future<Tag?> getById(String id);
  Future<Tag> findOrCreateByName(String name);

  /// Insert-or-update by [Tag.id] (unlike [findOrCreateByName], which
  /// dedupes by name and assigns a fresh id) — used by
  /// [FirebaseSyncRepository] to write back a remote tag verbatim,
  /// preserving its id/timestamps.
  Future<void> upsert(Tag tag);

  Future<void> delete(String id);
}
