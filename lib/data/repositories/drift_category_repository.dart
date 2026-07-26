import 'package:drift/drift.dart' show Value;

import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../local/dao/category_dao.dart';
import '../local/database/database.dart';

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._dao);

  final CategoryDao _dao;

  @override
  Stream<List<Category>> watchAll() => _dao.watchAll().map((rows) => rows.map(_mapRow).toList());

  @override
  Future<Category?> getById(String id) async {
    final CategoryRow? row = await _dao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> create(Category category) => _dao.insertOrUpdate(_toCompanion(category));

  @override
  Future<void> update(Category category) => _dao.insertOrUpdate(_toCompanion(category));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  Category _mapRow(CategoryRow row) => Category(
        id: row.id,
        name: row.name,
        color: row.color,
        icon: row.icon,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  CategoriesCompanion _toCompanion(Category category) => CategoriesCompanion(
        id: Value(category.id),
        name: Value(category.name),
        color: Value(category.color),
        icon: Value(category.icon),
        sortOrder: Value(category.sortOrder),
        createdAt: Value(category.createdAt),
        updatedAt: Value(category.updatedAt),
      );
}
