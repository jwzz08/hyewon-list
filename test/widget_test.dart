// The default `flutter create` counter smoke test referenced a `MyApp`
// widget that doesn't exist in hyewon_list (the real entry point,
// `HyewonListApp`, boots Firebase/Drift/window services and isn't a good
// target for a plain `pumpWidget` smoke test without a lot of fake
// plumbing). Replaced with a minimal sanity check so `flutter test` has a
// trivially-passing top-level test; the real coverage lives in
// test/features/calendar/recurring_event_service_test.dart and
// test/data/repositories/*_test.dart — see those files.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sanity check — test runner is wired up', () {
    expect(1 + 1, 2);
  });
}
