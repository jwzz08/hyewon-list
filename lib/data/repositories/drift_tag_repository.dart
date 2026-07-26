import 'package:drift/drift.dart' show Value;

import '../../core/utils/id_generator.dart';
import '../../domain/models/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../local/dao/tag_dao.dart';
import '../local/database/database.dart';

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._dao);

  final TagDao _dao;

  @override
  Stream<List<Tag>> watchAll() => _dao.watchAll().map((rows) => rows.map(_mapRow).toList());

  @override
  Future<Tag?> getById(String id) async {
    final TagRow? row = await _dao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<Tag> findOrCreateByName(String name) async {
    final TagRow? existing = await _dao.getByName(name);
    if (existing != null) return _mapRow(existing);
    final DateTime now = DateTime.now();
    final Tag tag = Tag(id: IdGenerator.newId(), name: name, createdAt: now, updatedAt: now);
    await _dao.insertOrUpdate(TagsCompanion(
      id: Value(tag.id),
      name: Value(tag.name),
      createdAt: Value(tag.createdAt),
      updatedAt: Value(tag.updatedAt),
    ));
    return tag;
  }

  @override
  Future<void> upsert(Tag tag) => _dao.insertOrUpdate(TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        createdAt: Value(tag.createdAt),
        updatedAt: Value(tag.updatedAt),
      ));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  Tag _mapRow(TagRow row) =>
      Tag(id: row.id, name: row.name, createdAt: row.createdAt, updatedAt: row.updatedAt);
}
