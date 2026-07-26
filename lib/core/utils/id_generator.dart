import 'package:uuid/uuid.dart';

/// Central place for generating IDs so every model/table uses the same
/// strategy. UUIDv4 avoids collisions when Firebase sync is added later
/// (client-generated IDs work offline and merge safely).
abstract final class IdGenerator {
  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
