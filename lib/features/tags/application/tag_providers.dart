import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/models/tag.dart';
import '../../../domain/repositories/tag_repository.dart';

final StreamProvider<List<Tag>> allTagsProvider =
    StreamProvider<List<Tag>>((ref) => ref.watch(tagRepositoryProvider).watchAll());

/// Thin facade over [TagRepository] for the tag management screen. Tags
/// only support create-by-name (dedup'd) and delete per the repository
/// interface — there's no rename, matching what's actually implemented in
/// [DriftTagRepository] today.
class TagActions {
  TagActions(this._repository);

  final TagRepository _repository;

  Future<Tag> findOrCreateByName(String name) => _repository.findOrCreateByName(name);

  Future<void> delete(String id) => _repository.delete(id);
}

final Provider<TagActions> tagActionsProvider =
    Provider<TagActions>((ref) => TagActions(ref.watch(tagRepositoryProvider)));
