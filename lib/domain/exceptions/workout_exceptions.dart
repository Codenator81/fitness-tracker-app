/// Domain Exceptions
///
/// Shared exception classes for workout-related business logic errors.

/// Exception thrown when workout validation fails
class WorkoutValidationException implements Exception {
  final String message;

  WorkoutValidationException(this.message);

  @override
  String toString() => 'WorkoutValidationException: $message';
}
