import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/get_all_workouts.dart';
import '../../domain/usecases/get_workout_by_id.dart';
import '../../domain/usecases/save_workout.dart';
import '../../domain/usecases/update_workout.dart';

/// Presentation Layer: Riverpod Providers
///
/// Sets up the dependency injection hierarchy:
/// Data Source → Repository → Use Cases → State Management

// ==================== Infrastructure Layer ====================

/// Provider for the local data source
/// This is the lowest level - handles Hive operations
final workoutLocalDataSourceProvider = Provider<WorkoutLocalDataSource>((ref) {
  return WorkoutLocalDataSource();
});

// ==================== Repository Layer ====================

/// Provider for the workout repository
/// Implements the domain interface using the data source
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dataSource = ref.watch(workoutLocalDataSourceProvider);
  return WorkoutRepositoryImpl(dataSource);
});

// ==================== Use Case Layer ====================

/// Provider for GetAllWorkouts use case
final getAllWorkoutsUseCaseProvider = Provider<GetAllWorkouts>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return GetAllWorkouts(repository);
});

/// Provider for SaveWorkout use case
final saveWorkoutUseCaseProvider = Provider<SaveWorkout>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return SaveWorkout(repository);
});

/// Provider for GetWorkoutById use case
final getWorkoutByIdUseCaseProvider = Provider<GetWorkoutById>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return GetWorkoutById(repository);
});

/// Provider for DeleteWorkout use case
final deleteWorkoutUseCaseProvider = Provider<DeleteWorkout>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return DeleteWorkout(repository);
});

/// Provider for UpdateWorkout use case
final updateWorkoutUseCaseProvider = Provider<UpdateWorkout>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return UpdateWorkout(repository);
});

// ==================== State Management Layer ====================

/// State Notifier for managing workout list
///
/// Handles loading, error, and success states using AsyncValue
class WorkoutListNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final GetAllWorkouts getAllWorkoutsUseCase;
  final DeleteWorkout deleteWorkoutUseCase;

  WorkoutListNotifier({
    required this.getAllWorkoutsUseCase,
    required this.deleteWorkoutUseCase,
  }) : super(const AsyncValue.loading()) {
    // Load workouts on initialization
    loadWorkouts();
  }

  /// Load all workouts from the repository
  Future<void> loadWorkouts() async {
    state = const AsyncValue.loading();
    try {
      final workouts = await getAllWorkoutsUseCase();
      state = AsyncValue.data(workouts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a workout and reload the list
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await deleteWorkoutUseCase(workoutId);
      // Reload workouts after deletion
      await loadWorkouts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a workout to the list (optimistic update)
  void addWorkout(Workout workout) {
    state.whenData((workouts) {
      state = AsyncValue.data([workout, ...workouts]);
    });
  }
}

/// Provider for WorkoutListNotifier
///
/// Manages the list of workouts with loading, error, and success states
final workoutListNotifierProvider =
    StateNotifierProvider<WorkoutListNotifier, AsyncValue<List<Workout>>>(
  (ref) {
    return WorkoutListNotifier(
      getAllWorkoutsUseCase: ref.watch(getAllWorkoutsUseCaseProvider),
      deleteWorkoutUseCase: ref.watch(deleteWorkoutUseCaseProvider),
    );
  },
);

/// Convenience provider for accessing the workout list state
final workoutListProvider = Provider<AsyncValue<List<Workout>>>((ref) {
  return ref.watch(workoutListNotifierProvider);
});
