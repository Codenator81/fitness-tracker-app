import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use Case: Get Workout By ID
///
/// Retrieves a single workout by its unique identifier.
class GetWorkoutById {
  final WorkoutRepository repository;

  GetWorkoutById(this.repository);

  /// Execute the use case
  ///
  /// Retrieves a workout by its ID.
  ///
  /// Returns the workout if found, null otherwise.
  Future<Workout?> call(String id) async {
    // Validate ID is not empty
    if (id.isEmpty) {
      throw ArgumentError('Workout ID cannot be empty');
    }

    return await repository.getWorkoutById(id);
  }
}
