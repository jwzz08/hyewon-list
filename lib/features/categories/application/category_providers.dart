import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/category.dart';
import '../../../domain/repositories/category_repository.dart';

/// All user-defined categories (Work/Study/Personal/Home + any custom ones),
/// shared by the task and event forms so both pick from the same list — the
/// product spec treats "life area" as one category system, not two.
final StreamProvider<List<Category>> allCategoriesProvider =
    StreamProvider<List<Category>>((ref) => ref.watch(categoryRepositoryProvider).watchAll());

/// Thin facade over [CategoryRepository] for the category management screen,
/// mirroring the `*Actions` pattern used by tasks/events.
class CategoryActions {
  CategoryActions(this._repository);

  final CategoryRepository _repository;

  Future<void> create({required String name, required int color, String? icon}) {
    final DateTime now = DateTime.now();
    return _repository.create(Category(
      id: IdGenerator.newId(),
      name: name,
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> update(Category category) => _repository.update(category);

  Future<void> delete(String id) => _repository.delete(id);
}

final Provider<CategoryActions> categoryActionsProvider =
    Provider<CategoryActions>((ref) => CategoryActions(ref.watch(categoryRepositoryProvider)));
