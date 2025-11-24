import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use Case: Update Workout
///
/// Handles updating an existing workout.
/// Includes business logic validation before updating.
class UpdateWorkout {
  final WorkoutRepository repository;

  UpdateWorkout(this.repository);

  /// Execute the use case
  ///
  /// Validates that the workout contains at least one exercise
  /// before updating in the repository.
  ///
  /// Throws [WorkoutValidationException] if validation fails.
  Future<void> call(Workout workout) async {
    // Business logic validation
    if (workout.exercises.isEmpty) {
      throw WorkoutValidationException(
        'Workout must contain at least one exercise',
      );
    }

    await repository.updateWorkout(workout);
  }
}

/// Exception thrown when workout validation fails
class WorkoutValidationException implements Exception {
  final String message;

  WorkoutValidationException(this.message);

  @override
  String toString() => 'WorkoutValidationException: $message';
}
