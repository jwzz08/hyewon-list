import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/utils/id_generator.dart';
import '../../domain/models/calendar_event.dart';
import '../../domain/repositories/calendar_event_repository.dart';
import '../local/dao/calendar_event_dao.dart';
import '../local/database/database.dart';

class DriftCalendarEventRepository implements CalendarEventRepository {
  DriftCalendarEventRepository(this._dao);

  final CalendarEventDao _dao;

  @override
  Stream<List<CalendarEvent>> watchAll() => _dao.watchAll().map(_mapRows);

  @override
  Stream<List<CalendarEvent>> watchInRange(DateTime start, DateTime end) =>
      _dao.watchInRange(start, end).map(_mapRows);

  @override
  Future<CalendarEvent?> getById(String id) async {
    final CalendarEventRow? row = await _dao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> create(CalendarEvent event) => _dao.insertOrUpdate(_toCompanion(event));

  @override
  Future<void> update(CalendarEvent event) => _dao.insertOrUpdate(_toCompanion(event));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  @override
  Future<void> moveToDateTime(String id, DateTime newStart) async {
    final CalendarEvent? event = await getById(id);
    if (event == null) return;
    final Duration duration = event.duration;
    await update(event.copyWith(
      startDateTime: newStart,
      endDateTime: newStart.add(duration),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<List<CalendarEvent>> searchByText(String query) async {
    final List<CalendarEventRow> rows = await _dao.searchByText(query);
    return _mapRows(rows);
  }

  List<CalendarEvent> _mapRows(List<CalendarEventRow> rows) => rows.map(_mapRow).toList();

  CalendarEvent _mapRow(CalendarEventRow row) {
    final List<DateTime> exceptionDates = (jsonDecode(row.recurrenceExceptionDatesJson) as List)
        .map((d) => DateTime.parse(d as String))
        .toList();
    return CalendarEvent(
      id: row.id,
      title: row.title,
      description: row.description,
      startDateTime: row.startDateTime,
      endDateTime: row.endDateTime,
      isAllDay: row.isAllDay,
      categoryId: row.categoryId,
      color: row.color,
      location: row.location,
      isRecurring: row.isRecurring,
      recurrenceRule: row.recurrenceRule,
      recurrenceEndDate: row.recurrenceEndDate,
      recurrenceCount: row.recurrenceCount,
      parentEventId: row.parentEventId,
      originalOccurrenceDate: row.originalOccurrenceDate,
      recurrenceExceptionDates: exceptionDates,
      reminderMinutesBefore: row.reminderMinutesBefore,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CalendarEventsCompanion _toCompanion(CalendarEvent event) => CalendarEventsCompanion(
        id: Value(event.id),
        title: Value(event.title),
        description: Value(event.description),
        startDateTime: Value(event.startDateTime),
        endDateTime: Value(event.endDateTime),
        isAllDay: Value(event.isAllDay),
        categoryId: Value(event.categoryId),
        color: Value(event.color),
        location: Value(event.location),
        isRecurring: Value(event.isRecurring),
        recurrenceRule: Value(event.recurrenceRule),
        recurrenceEndDate: Value(event.recurrenceEndDate),
        recurrenceCount: Value(event.recurrenceCount),
        parentEventId: Value(event.parentEventId),
        originalOccurrenceDate: Value(event.originalOccurrenceDate),
        recurrenceExceptionDatesJson: Value(
          jsonEncode(event.recurrenceExceptionDates.map((d) => d.toIso8601String()).toList()),
        ),
        reminderMinutesBefore: Value(event.reminderMinutesBefore),
        createdAt: Value(event.createdAt),
        updatedAt: Value(event.updatedAt),
      );

  static CalendarEvent newEvent({
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    bool isAllDay = false,
    String? categoryId,
    int? color,
    String? location,
  }) {
    final DateTime now = DateTime.now();
    return CalendarEvent(
      id: IdGenerator.newId(),
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isAllDay: isAllDay,
      categoryId: categoryId,
      color: color,
      location: location,
      createdAt: now,
      updatedAt: now,
    );
  }
}
