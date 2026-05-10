class ServerException implements Exception {
  final String message;

  ServerException({
    this.message = 'Server error occurred',
  });

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({
    this.message = 'Cache error occurred',
  });

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({
    this.message = 'No internet connection',
  });

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  AuthException({
    this.message = 'Authentication failed',
  });

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException({
    this.message = 'Validation failed',
  });

  @override
  String toString() => message;
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException({
    this.message = 'Database operation failed',
  });

  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;

  PermissionException({
    this.message = 'Permission denied',
  });

  @override
  String toString() => message;
}

class NotificationException implements Exception {
  final String message;

  NotificationException({
    this.message = 'Notification error occurred',
  });

  @override
  String toString() => message;
}