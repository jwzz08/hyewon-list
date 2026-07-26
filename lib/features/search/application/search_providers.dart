import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';

final StateProvider<String> searchQueryProvider = StateProvider<String>((ref) => '');

class SearchResults {
  const SearchResults({required this.tasks, required this.events});

  final List<Task> tasks;
  final List<CalendarEvent> events;

  bool get isEmpty => tasks.isEmpty && events.isEmpty;
  int get totalCount => tasks.length + events.length;
}

final FutureProvider<SearchResults> searchResultsProvider = FutureProvider<SearchResults>(
  (ref) async {
    final String query = ref.watch(searchQueryProvider).trim();
    if (query.isEmpty) {
      return const SearchResults(tasks: [], events: []);
    }
    final List<Task> tasks = await ref.watch(taskRepositoryProvider).searchByText(query);
    final List<CalendarEvent> events =
        await ref.watch(calendarEventRepositoryProvider).searchByText(query);
    return SearchResults(tasks: tasks, events: events);
  },
);
