import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/tag.dart';
import '../../../../shared/utils/undo_actions.dart';
import '../../../categories/application/category_providers.dart';
import '../../../tags/application/tag_providers.dart';
import 'settings_widgets.dart';

/// Same fixed palette the desktop category editor offers.
List<Color> get _palette => [
      AppColors.categoryWork,
      AppColors.categoryStudy,
      AppColors.categoryPersonal,
      AppColors.categoryHome,
      AppColors.priorityHigh,
      AppColors.priorityMedium,
      AppColors.priorityLow,
      AppColors.accentDark,
    ];

/// Settings > Categories: categories as list rows (add via bottom sheet,
/// delete with Undo) and tags as removable chips.
class MobileCategoriesPage extends ConsumerWidget {
  const MobileCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories = ref.watch(allCategoriesProvider).value ?? const <Category>[];
    final List<Tag> tags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          title: 'Categories',
          footer: 'Shared by tasks and events.',
          children: [
            for (final Category c in categories)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: Color(c.color), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(c.name, style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: 'Delete category',
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                        onPressed: () => deleteCategoryWithUndo(context, ref, c),
                      ),
                    ],
                  ),
                ),
              ),
            SettingsActionRow(
              icon: Icons.add_rounded,
              label: 'Add category',
              onTap: () => _showAddSheet(context, const _AddCategorySheet()),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Tags',
          footer: 'Free-form labels you can attach to tasks.',
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final Tag t in tags) _TagPill(tag: t),
                  ActionChip(
                    avatar: Icon(Icons.add_rounded, size: 18, color: AppColors.accentTextStrong),
                    label: const Text('Add tag'),
                    labelStyle: AppTextStyles.body(fontSize: 14, weight: FontWeight.w700, color: AppColors.accentTextStrong),
                    backgroundColor: AppColors.accentTint,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.standard,
                    onPressed: () => _showAddSheet(context, const _AddTagSheet()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _showAddSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.cardWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => sheet,
  );
}

class _TagPill extends ConsumerWidget {
  const _TagPill({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: AppColors.bgNeutral,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name, style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w700)),
          IconButton(
            tooltip: 'Delete tag',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: () => deleteTagWithUndo(context, ref, tag),
          ),
        ],
      ),
    );
  }
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final TextEditingController _name = TextEditingController();
  late Color _color = _palette.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _name.text.trim();
    if (name.isEmpty) return;
    ref.read(categoryActionsProvider).create(name: name, color: _color.value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New category', style: AppTextStyles.display(fontSize: 22)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Category name',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 18),
            Text('COLOR', style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final Color c in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      child: _color.value == c.value
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            BigButton(label: 'Add category', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

class _AddTagSheet extends ConsumerStatefulWidget {
  const _AddTagSheet();

  @override
  ConsumerState<_AddTagSheet> createState() => _AddTagSheetState();
}

class _AddTagSheetState extends ConsumerState<_AddTagSheet> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _name.text.trim();
    if (name.isNotEmpty) ref.read(tagActionsProvider).findOrCreateByName(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New tag', style: AppTextStyles.display(fontSize: 22)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Tag name',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 22),
            BigButton(label: 'Add tag', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
