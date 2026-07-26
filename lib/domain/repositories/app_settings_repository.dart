import '../models/app_settings.dart';

abstract class AppSettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
}
