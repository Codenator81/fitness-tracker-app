/// Domain Exceptions
///
/// Shared exception classes for workout-related business logic errors.

/// Base exception for all workout-related errors
///
/// All workout exceptions inherit from this base class to enable
/// consistent error handling across the application.
abstract class WorkoutException implements Exception {
  final String message;

  WorkoutException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when workout validation fails
class WorkoutValidationException extends WorkoutException {
  WorkoutValidationException(super.message);
}

/// Exception thrown when a workout is not found
class WorkoutNotFoundException extends WorkoutException {
  WorkoutNotFoundException(String id) : super('Workout not found: $id');
}

/// Exception thrown when workout storage operations fail
class WorkoutStorageException extends WorkoutException {
  WorkoutStorageException(super.message);
}
