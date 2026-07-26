import '../models/widget_preference.dart';

/// Device-local only. Never wrapped by a sync decorator (see
/// ARCHITECTURE.md "Sync boundaries").
abstract class WidgetPreferenceRepository {
  Stream<WidgetPreference> watch();
  Future<WidgetPreference> get();
  Future<void> save(WidgetPreference preference);
}
