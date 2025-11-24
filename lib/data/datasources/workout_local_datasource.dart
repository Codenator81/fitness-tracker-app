import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

/// Local Data Source: WorkoutLocalDataSource
///
/// Handles all Hive database operations for workouts.
/// This is the concrete implementation that interacts with the local storage.
class WorkoutLocalDataSource {
  static const String _boxName = 'workouts';
  Box<WorkoutModel>? _workoutBox;

  /// Initialize Hive and register adapters
  ///
  /// Must be called before any other operations.
  /// Registers type adapters and opens the Hive box.
  Future<void> init() async {
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Register adapters (only if not already registered)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ExerciseModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WorkoutModelAdapter());
      }

      // Open the workouts box
      _workoutBox = await Hive.openBox<WorkoutModel>(_boxName);
    } catch (e) {
      throw DataSourceException('Failed to initialize database: $e');
    }
  }

  /// Get the workout box, ensuring it's initialized
  Box<WorkoutModel> get _box {
    if (_workoutBox == null || !_workoutBox!.isOpen) {
      throw DataSourceException(
        'Database not initialized. Call init() first.',
      );
    }
    return _workoutBox!;
  }

  /// Save a workout to the database
  ///
  /// If a workout with the same ID exists, it will be overwritten.
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      await _box.put(workout.id, workout);
    } catch (e) {
      throw DataSourceException('Failed to save workout: $e');
    }
  }

  /// Get a single workout by ID
  ///
  /// Returns null if the workout is not found.
  Future<WorkoutModel?> getWorkout(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw DataSourceException('Failed to get workout: $e');
    }
  }

  /// Get all workouts from the database
  ///
  /// Returns an empty list if no workouts exist.
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw DataSourceException('Failed to get all workouts: $e');
    }
  }

  /// Delete a workout by ID
  ///
  /// Does nothing if the workout doesn't exist.
  Future<void> deleteWorkout(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw DataSourceException('Failed to delete workout: $e');
    }
  }

  /// Update an existing workout
  ///
  /// This is functionally the same as saveWorkout.
  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      await _box.put(workout.id, workout);
    } catch (e) {
      throw DataSourceException('Failed to update workout: $e');
    }
  }

  /// Clear all workouts from the database
  ///
  /// Useful for testing or resetting the app.
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw DataSourceException('Failed to clear all workouts: $e');
    }
  }

  /// Get a stream of all workouts for real-time updates
  ///
  /// Emits a new list whenever the database changes.
  Stream<List<WorkoutModel>> watchAllWorkouts() {
    try {
      return _box.watch().map((_) => _box.values.toList());
    } catch (e) {
      throw DataSourceException('Failed to watch workouts: $e');
    }
  }

  /// Close the database connection
  ///
  /// Should be called when the app is closing.
  Future<void> close() async {
    try {
      await _workoutBox?.close();
    } catch (e) {
      throw DataSourceException('Failed to close database: $e');
    }
  }
}

/// Exception thrown when a data source operation fails
class DataSourceException implements Exception {
  final String message;

  DataSourceException(this.message);

  @override
  String toString() => 'DataSourceException: $message';
}
