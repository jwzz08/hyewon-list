import '../models/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchAll();
  Future<Category?> getById(String id);
  Future<void> create(Category category);
  Future<void> update(Category category);
  Future<void> delete(String id);
}
