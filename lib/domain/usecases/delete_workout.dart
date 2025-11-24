import '../repositories/workout_repository.dart';

/// Use Case: Delete Workout
///
/// Handles deletion of a workout by its unique identifier.
class DeleteWorkout {
  final WorkoutRepository repository;

  DeleteWorkout(this.repository);

  /// Execute the use case
  ///
  /// Deletes a workout by its ID.
  ///
  /// Throws [ArgumentError] if the ID is empty.
  Future<void> call(String id) async {
    // Validate ID is not empty
    if (id.isEmpty) {
      throw ArgumentError('Workout ID cannot be empty');
    }

    await repository.deleteWorkout(id);
  }
}
