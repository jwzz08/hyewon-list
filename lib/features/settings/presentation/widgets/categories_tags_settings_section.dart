import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/tag.dart';
import '../../../../shared/utils/undo_actions.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../../categories/application/category_providers.dart';
import '../../../tags/application/tag_providers.dart';

/// A fixed palette rather than a full color wheel — keeps custom categories
/// visually consistent with the mockup's category colors (Work/Study/
/// Personal/Home) instead of letting the grid fill up with arbitrary hues.
///
/// A getter (not `const`) because `categoryStudy`/`accentDark` are
/// theme-preset-driven (see app_colors.dart) and so can no longer be
/// compile-time constants.
List<Color> get _categoryPalette => [
      AppColors.categoryWork,
      AppColors.categoryStudy,
      AppColors.categoryPersonal,
      AppColors.categoryHome,
      AppColors.priorityHigh,
      AppColors.priorityMedium,
      AppColors.priorityLow,
      AppColors.accentDark,
    ];

/// Category and tag CRUD — both data layers already existed
/// (`CategoryRepository`/`TagRepository` + Drift tables), this section is
/// the first UI for managing them (see ARCHITECTURE.md "Tag CRUD UI,
/// category CRUD UI").
class CategoriesTagsSettingsSection extends ConsumerWidget {
  const CategoriesTagsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories = ref.watch(allCategoriesProvider).value ?? const <Category>[];
    final List<Tag> tags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return SettingsSection(
      title: 'CATEGORIES & TAGS',
      subtitle: 'Categories are shared by tasks and events. Tags are free-form labels.',
      children: [
        Text('Categories', style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final Category category in categories) _CategoryRow(category: category),
        const SizedBox(height: 6),
        const _AddCategoryRow(),
        const SizedBox(height: 18),
        Text('Tags', style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final Tag tag in tags) _TagChip(tag: tag),
            const _AddTagChip(),
          ],
        ),
      ],
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: Color(category.color), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(category.name, style: AppTextStyles.body(fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            tooltip: 'Delete category',
            // Matches the task/event delete pattern app-wide (see
            // shared/utils/undo_actions.dart): delete immediately, offer a
            // 5-second Undo snackbar, instead of a separate "are you sure?"
            // confirm dialog — this used to have one, but since the delete
            // is now actually reversible there's nothing left for a confirm
            // step to protect against.
            onPressed: () => deleteCategoryWithUndo(context, ref, category),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryRow extends ConsumerStatefulWidget {
  const _AddCategoryRow();

  @override
  ConsumerState<_AddCategoryRow> createState() => _AddCategoryRowState();
}

class _AddCategoryRowState extends ConsumerState<_AddCategoryRow> {
  final TextEditingController _controller = TextEditingController();
  Color _selectedColor = _categoryPalette.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _controller.text.trim();
    if (name.isEmpty) return;
    ref.read(categoryActionsProvider).create(name: name, color: _selectedColor.value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final Color color in _categoryPalette)
          GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              margin: const EdgeInsets.only(right: 5),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: _selectedColor == color ? Border.all(color: AppColors.textBody, width: 2) : null,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(hintText: 'New category name', isDense: true),
            style: AppTextStyles.body(fontSize: 12.5),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: Icon(Icons.add_circle, size: 20, color: AppColors.accent),
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _TagChip extends ConsumerWidget {
  const _TagChip({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.bgNeutral,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name, style: AppTextStyles.meta(fontSize: 11)),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => deleteTagWithUndo(context, ref, tag),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.close, size: 12, color: AppColors.textFaint),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTagChip extends ConsumerStatefulWidget {
  const _AddTagChip();

  @override
  ConsumerState<_AddTagChip> createState() => _AddTagChipState();
}

class _AddTagChipState extends ConsumerState<_AddTagChip> {
  bool _editing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _controller.text.trim();
    if (name.isNotEmpty) {
      ref.read(tagActionsProvider).findOrCreateByName(name);
    }
    _controller.clear();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return GestureDetector(
        onTap: () => setState(() => _editing = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text('+ Add tag', style: AppTextStyles.meta(fontSize: 11)),
        ),
      );
    }
    return SizedBox(
      width: 120,
      child: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (_) => _submit(),
        onEditingComplete: _submit,
        decoration: const InputDecoration(hintText: 'Tag name', isDense: true),
        style: AppTextStyles.body(fontSize: 12),
      ),
    );
  }
}
