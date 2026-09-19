import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/tag.dart';
import '../../../../shared/utils/undo_actions.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../../shared/widgets/components/bulk_action_bar.dart';
import '../../../../shared/widgets/components/empty_state.dart';
import '../../../../shared/widgets/components/event_card.dart';
import '../../../../shared/widgets/components/filter_chip_group.dart';
import '../../../../shared/widgets/components/search_bar_widget.dart';
import '../../../../shared/widgets/components/task_row.dart';
import '../../../categories/application/category_providers.dart';
import '../../../tags/application/tag_providers.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/search_providers.dart';

enum _DateFilter { all, today, thisWeek, thisMonth }

/// Global search across task titles/memos and event titles/memos (spec
/// section 11), with a date filter, category filter (tasks + events) and
/// tag filter (tasks only — [CalendarEvent] has no tag field) plus a
/// Ctrl+K shortcut (wired in RootShell) to jump here from anywhere.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  _DateFilter _dateFilter = _DateFilter.all;
  String? _categoryFilter; // null = All categories
  String? _tagFilter; // null = All tags

  // Multi-select/bulk actions (tasks only — search results mix tasks and
  // events, but bulk complete/delete only makes sense for tasks, which have
  // a binary done/not-done state; events don't).
  bool _selectionMode = false;
  final Set<String> _selectedTaskIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedTaskIds.clear();
    });
  }

  void _toggleTaskSelected(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  bool _matchesDateFilter(DateTime? date) {
    if (_dateFilter == _DateFilter.all) return true;
    if (date == null) return false;
    final DateTime now = DateTime.now();
    switch (_dateFilter) {
      case _DateFilter.today:
        return AppDateUtils.isSameDay(date, now);
      case _DateFilter.thisWeek:
        final DateTime start = AppDateUtils.startOfWeek(now);
        // `end` is the last *inclusive calendar day*, not a precise cutoff
        // instant — bump to the start of the following day before comparing
        // (same fix as CalendarEventDao.watchInRange/RecurringEventService.
        // generateOccurrences) so a calendar event's real time-of-day
        // (`date` is `e.startDateTime` for events, not just a task's
        // always-midnight `dueDate`) landing on the week's last day still
        // matches instead of failing `!date.isAfter(end)`.
        final DateTime exclusiveEnd = start.add(const Duration(days: 7));
        return !date.isBefore(start) && date.isBefore(exclusiveEnd);
      case _DateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
      case _DateFilter.all:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SearchResults> resultsAsync = ref.watch(searchResultsProvider);
    final TaskActions taskActions = ref.watch(taskActionsProvider);
    final List<Category> categories = ref.watch(allCategoriesProvider).value ?? const <Category>[];
    final List<Tag> tags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Search', style: AppTextStyles.display()),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _toggleSelectionMode,
                    icon: Icon(_selectionMode ? Icons.close : Icons.checklist, size: 16),
                    label: Text(_selectionMode ? 'Cancel' : 'Select'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SearchBarWidget(
                autofocus: true,
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Date', style: AppTextStyles.meta(fontSize: 10)),
                  const SizedBox(width: 8),
                  FilterChipGroup<_DateFilter>(
                    options: _DateFilter.values,
                    labelBuilder: (f) => switch (f) {
                      _DateFilter.all => 'All dates',
                      _DateFilter.today => 'Today',
                      _DateFilter.thisWeek => 'This week',
                      _DateFilter.thisMonth => 'This month',
                    },
                    value: _dateFilter,
                    onChanged: (f) => setState(() => _dateFilter = f),
                  ),
                ],
              ),
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Category', style: AppTextStyles.meta(fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChipGroup<String?>(
                        options: [null, ...categories.map((c) => c.id)],
                        labelBuilder: (id) =>
                            id == null ? 'All' : categories.firstWhere((c) => c.id == id).name,
                        value: _categoryFilter,
                        onChanged: (id) => setState(() => _categoryFilter = id),
                      ),
                    ),
                  ],
                ),
              ],
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Tag', style: AppTextStyles.meta(fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChipGroup<String?>(
                        options: [null, ...tags.map((t) => t.id)],
                        labelBuilder: (id) =>
                            id == null ? 'All' : tags.firstWhere((t) => t.id == id).name,
                        value: _tagFilter,
                        onChanged: (id) => setState(() => _tagFilter = id),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: resultsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Search failed', style: AppTextStyles.meta())),
                  data: (results) {
                    final List<Task> tasks = results.tasks
                        .where((t) => _matchesDateFilter(t.dueDate))
                        .where((t) => _categoryFilter == null || t.categoryId == _categoryFilter)
                        .where((t) => _tagFilter == null || t.tagIds.contains(_tagFilter))
                        .toList();
                    // Events have no tag field — a tag filter can never
                    // match one, so the list is correctly empty rather than
                    // showing untagged events under an active tag filter.
                    final List<CalendarEvent> events = _tagFilter != null
                        ? const <CalendarEvent>[]
                        : results.events
                            .where((e) => _matchesDateFilter(e.startDateTime))
                            .where((e) => _categoryFilter == null || e.categoryId == _categoryFilter)
                            .toList();

                    if (results.isEmpty) {
                      return const EmptyState(
                        message: 'Start typing to search tasks and events',
                        icon: Icons.search,
                      );
                    }
                    if (tasks.isEmpty && events.isEmpty) {
                      return const EmptyState(
                        message: 'No matching tasks or events',
                        icon: Icons.search_off,
                      );
                    }
                    final List<Task> selectedTasks =
                        tasks.where((t) => _selectedTaskIds.contains(t.id)).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectionMode && selectedTasks.isNotEmpty) ...[
                          BulkActionBar(
                            count: selectedTasks.length,
                            onComplete: () async {
                              for (final Task t in selectedTasks) {
                                await taskActions.setCompleted(t.id, true);
                              }
                              setState(_selectedTaskIds.clear);
                            },
                            onDelete: () async {
                              await deleteTasksWithUndo(context, ref, selectedTasks);
                              setState(_selectedTaskIds.clear);
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                        Expanded(
                          child: ListView(
                            children: [
                              Text('${tasks.length + events.length} results',
                                  style: AppTextStyles.meta()),
                              const SizedBox(height: 8),
                              ...tasks.map(
                                (t) => Row(
                                  children: [
                                    if (_selectionMode)
                                      Checkbox(
                                        value: _selectedTaskIds.contains(t.id),
                                        onChanged: (_) => _toggleTaskSelected(t.id),
                                      ),
                                    Expanded(
                                      child: TaskRow(
                                        task: t,
                                        showDueDateLabel: true,
                                        onToggle: (v) => taskActions.setCompleted(t.id, v),
                                        onTap: () => _selectionMode
                                            ? _toggleTaskSelected(t.id)
                                            : showEditTaskDialog(context, t),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...events.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: EventCard(
                                    event: e,
                                    onTap: () => showEditEventDialog(
                                      context,
                                      CalendarEventOccurrence(
                                        sourceEvent: e,
                                        occurrenceStart: e.startDateTime,
                                        occurrenceEnd: e.endDateTime,
                                        isGeneratedRecurrence: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

