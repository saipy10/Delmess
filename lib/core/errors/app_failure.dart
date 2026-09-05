/// Base class for all domain and data failures in the application.
abstract class AppFailure {
  final String message;
  final String? code;
  final dynamic details;

  const AppFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'AppFailure($code): $message';
}

class GeneralFailure extends AppFailure {
  const GeneralFailure([
    super.message = 'An unexpected error occurred.',
    String? code,
    dynamic details,
  ]) : super(code: code, details: details);
}

class StorageFailure extends AppFailure {
  const StorageFailure([
    super.message = 'Storage operation failed.',
    String? code,
    dynamic details,
  ]) : super(code: code, details: details);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
    String? code,
    dynamic details,
  ]) : super(code: code, details: details);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([
    super.message = 'Required permission was not granted.',
    String? code,
    dynamic details,
  ]) : super(code: code, details: details);
}
