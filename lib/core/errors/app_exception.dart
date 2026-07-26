/// Base class for domain-level failures so repositories/use cases can throw
/// something more meaningful than raw platform exceptions, and the UI layer
/// can catch one type.
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? ' ($cause)' : ''}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

class ImportExportException extends AppException {
  const ImportExportException(super.message, {super.cause});
}

class SchemaVersionMismatchException extends ImportExportException {
  const SchemaVersionMismatchException(int found, int expected)
      : super('Import file schema version $found does not match expected $expected.');
}
