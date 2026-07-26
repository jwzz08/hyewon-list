import 'package:drift/drift.dart';

/// Single-row table (id is always `'default'` for MVP — one window per
/// device). Device-local; never synced. See ARCHITECTURE.md "Sync boundaries".
@DataClassName('WidgetPreferenceRow')
class WidgetPreferences extends Table {
  TextColumn get id => text()();
  RealColumn get windowX => real().nullable()();
  RealColumn get windowY => real().nullable()();
  RealColumn get windowWidth => real().withDefault(const Constant(360))();
  RealColumn get windowHeight => real().withDefault(const Constant(480))();
  RealColumn get opacity => real().withDefault(const Constant(100))();
  RealColumn get backgroundOpacity => real().withDefault(const Constant(100))();
  RealColumn get cardOpacity => real().withDefault(const Constant(100))();
  BoolColumn get isAlwaysOnTop => boolean().withDefault(const Constant(false))();
  BoolColumn get isPositionLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isSizeLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get showInTaskbar => boolean().withDefault(const Constant(true))();
  TextColumn get widgetMode => text().withDefault(const Constant('expanded'))();
  TextColumn get themePresetId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
