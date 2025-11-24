import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../models/workout_model.dart';

/// Repository Implementation: WorkoutRepositoryImpl
///
/// Implements the WorkoutRepository interface from the domain layer.
/// This bridges the domain and data layers by:
/// 1. Converting domain entities to data models
/// 2. Calling the data source
/// 3. Converting data models back to domain entities
/// 4. Handling errors and exceptions
///
/// This ensures the domain layer remains independent of data implementation details.
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource dataSource;

  WorkoutRepositoryImpl(this.dataSource);

  @override
  Future<void> saveWorkout(Workout workout) async {
    try {
      // Step 1: Convert domain entity to data model
      final workoutModel = WorkoutModel.fromEntity(workout);

      // Step 2: Call data source
      await dataSource.saveWorkout(workoutModel);
    } catch (e) {
      // Step 4: Handle errors
      throw RepositoryException('Failed to save workout: $e');
    }
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    try {
      // Step 2: Call data source
      final workoutModel = await dataSource.getWorkout(id);

      // Step 3: Convert data model to domain entity (if found)
      return workoutModel?.toEntity();
    } catch (e) {
      // Step 4: Handle errors
      throw RepositoryException('Failed to get workout by ID: $e');
    }
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    try {
      // Step 2: Call data source
      final workoutModels = await dataSource.getAllWorkouts();

      // Step 3: Convert all data models to domain entities
      return workoutModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Step 4: Handle errors
      throw RepositoryException('Failed to get all workouts: $e');
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      // Step 2: Call data source (no conversion needed for delete)
      await dataSource.deleteWorkout(id);
    } catch (e) {
      // Step 4: Handle errors
      throw RepositoryException('Failed to delete workout: $e');
    }
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    try {
      // Step 1: Convert domain entity to data model
      final workoutModel = WorkoutModel.fromEntity(workout);

      // Step 2: Call data source
      await dataSource.updateWorkout(workoutModel);
    } catch (e) {
      // Step 4: Handle errors
      throw RepositoryException('Failed to update workout: $e');
    }
  }
}

/// Exception thrown when a repository operation fails
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
