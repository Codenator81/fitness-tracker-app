import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use Case: Save Workout
///
/// Handles saving a new workout or updating an existing one.
/// Includes business logic validation before saving.
class SaveWorkout {
  final WorkoutRepository repository;

  SaveWorkout(this.repository);

  /// Execute the use case
  ///
  /// Validates that the workout contains at least one exercise
  /// before saving to the repository.
  ///
  /// Throws [WorkoutValidationException] if validation fails
  Future<void> call(Workout workout) async {
    // Business logic validation
    if (workout.exercises.isEmpty) {
      throw WorkoutValidationException(
        'Workout must contain at least one exercise',
      );
    }

    await repository.saveWorkout(workout);
  }
}

/// Exception thrown when workout validation fails
class WorkoutValidationException implements Exception {
  final String message;

  WorkoutValidationException(this.message);

  @override
  String toString() => 'WorkoutValidationException: $message';
}
