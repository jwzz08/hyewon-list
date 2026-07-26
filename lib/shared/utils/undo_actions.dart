import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/calendar_event.dart';
import '../../domain/models/category.dart';
import '../../domain/models/tag.dart';
import '../../domain/models/task.dart';
import '../../domain/models/theme_preset.dart';
import '../../features/calendar/application/calendar_providers.dart';
import '../../features/settings/application/theme_preset_providers.dart';
import '../../features/tasks/application/task_providers.dart';

/// Deletes [task] immediately (no separate "are you sure?" confirmation —
/// this Undo snackbar replaces that pattern everywhere a task is deleted:
/// AddItemDialog's Delete button, SearchScreen's multi-select bulk delete)
/// and offers a 2-second window to restore it. `TaskRepository.create` has
/// insert-or-update semantics (see ImportExportService's import path, which
/// relies on the same thing), so recreating the exact same [Task] — same id
/// and all — is a safe, simple "undo": nothing else in the app needs to
/// know the row was ever gone.
Future<void> deleteTaskWithUndo(BuildContext context, WidgetRef ref, Task task) async {
  final TaskActions actions = ref.read(taskActionsProvider);
  await actions.delete(task.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Deleted "${task.title}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => actions.create(task),
      ),
      duration: const Duration(seconds: 2),
      // Flutter 3.38 changed the default so a SnackBar with an action no
      // longer auto-dismisses at all (it waits for the user to interact) —
      // see https://docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update.
      // Every Undo snackbar here has an action button, so without this
      // they'd all sit on screen indefinitely instead of respecting
      // `duration`. `persist: false` restores the old auto-dismiss behavior.
      persist: false,
    ));
}

/// Bulk variant used by SearchScreen's multi-select bar — deletes every
/// task in [tasks] immediately and offers one Undo for the whole batch.
Future<void> deleteTasksWithUndo(BuildContext context, WidgetRef ref, List<Task> tasks) async {
  if (tasks.isEmpty) return;
  final TaskActions actions = ref.read(taskActionsProvider);
  for (final Task task in tasks) {
    await actions.delete(task.id);
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        tasks.length == 1 ? 'Deleted "${tasks.first.title}"' : 'Deleted ${tasks.length} tasks',
      ),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () async {
          for (final Task task in tasks) {
            await actions.create(task);
          }
        },
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Same pattern as [deleteTaskWithUndo], for a [CalendarEvent] (always the
/// full row passed in — for a recurring series, that's "entire series",
/// matching AddItemDialog's existing delete-scope semantics).
Future<void> deleteEventWithUndo(BuildContext context, WidgetRef ref, CalendarEvent event) async {
  final CalendarEventActions actions = ref.read(calendarEventActionsProvider);
  await actions.delete(event.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Deleted "${event.title}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => actions.create(event),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Same pattern as [deleteTaskWithUndo], for a [Category] — goes straight to
/// `CategoryRepository.create` (an upsert, see DriftCategoryRepository)
/// rather than `CategoryActions.create`, since that facade method only
/// builds a *brand new* category from a name/color pair (fresh id); undo
/// needs the exact original id restored so any task/event still referencing
/// it by id (they keep a dangling category id rather than being cleared —
/// they just show no label/color until the category exists again)
/// re-links correctly once undone.
Future<void> deleteCategoryWithUndo(BuildContext context, WidgetRef ref, Category category) async {
  final repository = ref.read(categoryRepositoryProvider);
  await repository.delete(category.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Deleted "${category.name}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => repository.create(category),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Same pattern as [deleteCategoryWithUndo], for a [Tag] — goes straight to
/// `TagRepository.upsert` (not `TagActions.findOrCreateByName`, which dedupes
/// by name and would assign a fresh id) so the exact original id comes back,
/// keeping any task's `tagIdsJson` referencing it correctly linked.
Future<void> deleteTagWithUndo(BuildContext context, WidgetRef ref, Tag tag) async {
  final repository = ref.read(tagRepositoryProvider);
  await repository.delete(tag.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Deleted "${tag.name}" tag'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => repository.upsert(tag),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Saves an edit to [updated] (already a `.copyWith(...)` of [original])
/// and offers a 2-second Undo that writes [original] straight back — same
/// "recreate/rewrite the exact previous row" idea as the delete-undo
/// helpers above, just via `update` instead of `create`/`delete`. Used by
/// AddItemDialog's Save button for a plain task edit.
Future<void> editTaskWithUndo(
  BuildContext context,
  WidgetRef ref,
  Task original,
  Task updated,
) async {
  final TaskActions actions = ref.read(taskActionsProvider);
  await actions.update(updated);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Updated "${updated.title}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => actions.update(original),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Same pattern as [editTaskWithUndo], for a [CalendarEvent]. Only safe to
/// use where the save is a single `update` call on one row — AddItemDialog
/// uses this for a non-recurring event and for the "entire series" edit
/// scope, but deliberately NOT for the "this occurrence" or "this and
/// following" scopes, since those mutate *two* rows each (e.g. create a
/// detached occurrence AND apply an exception date to the parent) and a
/// single `update(original)` on undo wouldn't cleanly reverse either half —
/// getting that right needs a real two-step revert this pass doesn't
/// attempt.
Future<void> editEventWithUndo(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent original,
  CalendarEvent updated,
) async {
  final CalendarEventActions actions = ref.read(calendarEventActionsProvider);
  await actions.update(updated);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Updated "${updated.title}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => actions.update(original),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}

/// Same pattern as [deleteTaskWithUndo], for a [ThemePreset]. Unlike
/// category/tag deletion, nothing else references a preset by id after
/// it's gone (`WidgetPreference.themePresetId` just falls back to
/// [ThemePreset.defaultPreset] — see `activeThemePresetProvider`), so this
/// is a pure convenience undo rather than a data-integrity one.
Future<void> deleteThemePresetWithUndo(BuildContext context, WidgetRef ref, ThemePreset preset) async {
  final actions = ref.read(themePresetActionsProvider);
  await actions.delete(preset.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Deleted "${preset.name}"'),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.accentTintLightest,
        onPressed: () => actions.create(preset),
      ),
      duration: const Duration(seconds: 2),
      persist: false, // see deleteTaskWithUndo's doc comment above
    ));
}
