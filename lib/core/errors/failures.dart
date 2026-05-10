abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server failure',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Cache failure',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failure',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation failure',
  ]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([
    super.message = 'Database failure',
  ]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Permission denied',
  ]);
}

class NotificationFailure extends Failure {
  const NotificationFailure([
    super.message = 'Notification failure',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Unexpected error occurred',
  ]);
}