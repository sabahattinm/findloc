/// Base class for all failures in the application
abstract class Failure {
  const Failure([this.message]);

  final String? message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

/// Subscription related failures
class SubscriptionFailure extends Failure {
  const SubscriptionFailure([super.message]);
}

/// Location detection related failures
class LocationDetectionFailure extends Failure {
  const LocationDetectionFailure([super.message]);
}

/// Camera related failures
class CameraFailure extends Failure {
  const CameraFailure([super.message]);
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message]);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

/// Generic failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}
