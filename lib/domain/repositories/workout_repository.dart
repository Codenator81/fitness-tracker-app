import '../entities/workout.dart';

/// Domain Repository Interface: WorkoutRepository
///
/// Abstract contract defining workout data operations.
/// This interface lives in the domain layer but will be implemented
/// in the data layer, following the Dependency Inversion Principle.
///
/// The domain layer defines WHAT operations are needed,
/// while the data layer defines HOW they are executed.
abstract class WorkoutRepository {
  /// Save a new workout or update an existing one
  ///
  /// Throws an exception if the save operation fails
  Future<void> saveWorkout(Workout workout);

  /// Retrieve a single workout by its unique identifier
  ///
  /// Returns the workout if found, null otherwise
  Future<Workout?> getWorkoutById(String id);

  /// Retrieve all workouts, typically sorted by date (newest first)
  ///
  /// Returns an empty list if no workouts exist
  Future<List<Workout>> getAllWorkouts();

  /// Delete a workout by its unique identifier
  ///
  /// Throws an exception if the delete operation fails
  /// Does nothing if the workout doesn't exist
  Future<void> deleteWorkout(String id);

  /// Update an existing workout
  ///
  /// Throws an exception if the workout doesn't exist or update fails
  Future<void> updateWorkout(Workout workout);
}
