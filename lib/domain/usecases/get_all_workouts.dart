import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use Case: Get All Workouts
///
/// Retrieves all workouts from the repository.
/// Includes business logic for sorting workouts by date (newest first).
class GetAllWorkouts {
  final WorkoutRepository repository;

  GetAllWorkouts(this.repository);

  /// Execute the use case
  ///
  /// Retrieves all workouts and sorts them by date in descending order
  /// (newest workouts first).
  ///
  /// Returns an empty list if no workouts exist.
  Future<List<Workout>> call() async {
    final workouts = await repository.getAllWorkouts();

    // Business logic: Sort by date, newest first
    workouts.sort((a, b) => b.date.compareTo(a.date));

    return workouts;
  }
}
