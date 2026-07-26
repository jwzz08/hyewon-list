import 'package:drift/drift.dart';

@DataClassName('ThemePresetRow')
class ThemePresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get backgroundColor => integer()();
  IntColumn get cardColor => integer()();
  IntColumn get textColor => integer()();
  IntColumn get accentColor => integer()();
  RealColumn get borderRadius => real().withDefault(const Constant(18))();
  RealColumn get shadowIntensity => real().withDefault(const Constant(0.5))();
  RealColumn get blurIntensity => real().withDefault(const Constant(0.5))();
  TextColumn get fontFamily => text().withDefault(const Constant('Nunito'))();
  RealColumn get fontSize => real().withDefault(const Constant(13))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
