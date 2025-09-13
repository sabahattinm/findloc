/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'An unknown exception occurred';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException([super.message]);
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException([super.message]);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException([super.message]);
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException([super.message]);
}

/// Subscription related exceptions
class SubscriptionException extends AppException {
  const SubscriptionException([super.message]);
}

/// Location detection related exceptions
class LocationDetectionException extends AppException {
  const LocationDetectionException([super.message]);
}

/// Camera related exceptions
class CameraException extends AppException {
  const CameraException([super.message]);
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException([super.message]);
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException([super.message]);
}

/// Generic exception for unexpected errors
class UnknownException extends AppException {
  const UnknownException([super.message]);
}
