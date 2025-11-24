# Workout Tracker App - Clean Architecture Design

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Domain Layer](#domain-layer)
3. [Data Layer](#data-layer)
4. [Presentation Layer](#presentation-layer)
5. [Dependency Flow](#dependency-flow)
6. [Riverpod Provider Architecture](#riverpod-provider-architecture)
7. [Complete Folder Structure](#complete-folder-structure)
8. [Implementation Rationale](#implementation-rationale)

---

## Architecture Overview

This workout tracker follows Clean Architecture principles with three distinct layers:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (UI, State Management, Providers)      │
│  - Screens, Widgets                     │
│  - Riverpod Providers                   │
│  - View Models / State Notifiers        │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│            DATA LAYER                    │
│  (Repository Implementations, DTOs)      │
│  - Repository Implementations           │
│  - Data Sources (Local)                 │
│  - Data Models (Hive)                   │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│           DOMAIN LAYER                   │
│  (Business Logic, Entities, Contracts)   │
│  - Entities (Pure Dart)                 │
│  - Repository Interfaces                │
│  - Use Cases                            │
│  - Value Objects                        │
└──────────────────────────────────────────┘
```

**Key Principle**: Dependencies point INWARD. Domain knows nothing about outer layers.

---

## Domain Layer

The Domain layer is the heart of the application. It contains:
- Business entities (pure Dart classes)
- Repository interfaces (abstract contracts)
- Use cases (business operations)
- Value objects and domain logic

### 1. Domain Entities

#### 1.1 Exercise Entity
```dart
// lib/domain/entities/exercise.dart

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String? notes;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
  });

  // Calculate volume for this exercise (sets × reps × weight)
  double get volume => sets * reps * weight;

  // Copy with method for immutability
  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

#### 1.2 Workout Entity
```dart
// lib/domain/entities/workout.dart

class Workout {
  final String id;
  final DateTime date;
  final List<Exercise> exercises;
  final String? title;
  final String? notes;

  const Workout({
    required this.id,
    required this.date,
    required this.exercises,
    this.title,
    this.notes,
  });

  // Calculate total volume for entire workout
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
  }

  // Get total number of sets
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  // Get total number of exercises
  int get exerciseCount => exercises.length;

  // Duration tracking (if needed later)
  Duration? get duration => null; // Placeholder for future enhancement

  Workout copyWith({
    String? id,
    DateTime? date,
    List<Exercise>? exercises,
    String? title,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workout &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

### 2. Repository Interfaces

Repository interfaces define the contract for data operations. They live in the domain layer but are implemented in the data layer.

#### 2.1 Workout Repository Interface
```dart
// lib/domain/repositories/workout_repository.dart

import '../entities/workout.dart';

abstract class WorkoutRepository {
  /// Retrieve all workouts, sorted by date (newest first)
  Future<List<Workout>> getAllWorkouts();

  /// Retrieve a single workout by ID
  Future<Workout?> getWorkoutById(String id);

  /// Retrieve workouts within a date range
  Future<List<Workout>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save a new workout or update existing
  Future<void> saveWorkout(Workout workout);

  /// Delete a workout by ID
  Future<void> deleteWorkout(String id);

  /// Get total volume for a specific date
  Future<double> getTotalVolumeForDate(DateTime date);

  /// Get workout statistics for a date range
  Future<WorkoutStats> getWorkoutStats({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Stream of all workouts (for real-time updates)
  Stream<List<Workout>> watchAllWorkouts();
}
```

#### 2.2 Domain Value Objects
```dart
// lib/domain/entities/workout_stats.dart

class WorkoutStats {
  final int totalWorkouts;
  final double totalVolume;
  final int totalSets;
  final int totalExercises;
  final DateTime startDate;
  final DateTime endDate;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.totalSets,
    required this.totalExercises,
    required this.startDate,
    required this.endDate,
  });

  double get averageVolumePerWorkout =>
      totalWorkouts > 0 ? totalVolume / totalWorkouts : 0;

  double get averageSetsPerWorkout =>
      totalWorkouts > 0 ? totalSets / totalWorkouts : 0;
}
```

### 3. Use Cases

Use cases encapsulate single business operations. Each use case should do ONE thing.

#### 3.1 Get All Workouts Use Case
```dart
// lib/domain/usecases/get_all_workouts.dart

import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

class GetAllWorkouts {
  final WorkoutRepository repository;

  GetAllWorkouts(this.repository);

  Future<List<Workout>> call() async {
    return await repository.getAllWorkouts();
  }
}
```

#### 3.2 Save Workout Use Case
```dart
// lib/domain/usecases/save_workout.dart

import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

class SaveWorkout {
  final WorkoutRepository repository;

  SaveWorkout(this.repository);

  Future<void> call(Workout workout) async {
    // Business logic validation can go here
    if (workout.exercises.isEmpty) {
      throw WorkoutValidationException('Workout must contain at least one exercise');
    }

    await repository.saveWorkout(workout);
  }
}

class WorkoutValidationException implements Exception {
  final String message;
  WorkoutValidationException(this.message);

  @override
  String toString() => 'WorkoutValidationException: $message';
}
```

#### 3.3 Delete Workout Use Case
```dart
// lib/domain/usecases/delete_workout.dart

import '../repositories/workout_repository.dart';

class DeleteWorkout {
  final WorkoutRepository repository;

  DeleteWorkout(this.repository);

  Future<void> call(String workoutId) async {
    await repository.deleteWorkout(workoutId);
  }
}
```

#### 3.4 Get Workout Stats Use Case
```dart
// lib/domain/usecases/get_workout_stats.dart

import '../entities/workout_stats.dart';
import '../repositories/workout_repository.dart';

class GetWorkoutStats {
  final WorkoutRepository repository;

  GetWorkoutStats(this.repository);

  Future<WorkoutStats> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getWorkoutStats(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
```

#### 3.5 Calculate Total Volume Use Case
```dart
// lib/domain/usecases/calculate_total_volume.dart

import '../entities/workout.dart';

class CalculateTotalVolume {
  // Pure business logic - no repository needed
  double call(List<Workout> workouts) {
    return workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
  }

  double forWorkout(Workout workout) {
    return workout.totalVolume;
  }

  double forDate(List<Workout> workouts, DateTime date) {
    final workoutsOnDate = workouts.where((w) =>
        w.date.year == date.year &&
        w.date.month == date.month &&
        w.date.day == date.day);
    return call(workoutsOnDate.toList());
  }
}
```

#### 3.6 Get Workouts By Date Range Use Case
```dart
// lib/domain/usecases/get_workouts_by_date_range.dart

import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

class GetWorkoutsByDateRange {
  final WorkoutRepository repository;

  GetWorkoutsByDateRange(this.repository);

  Future<List<Workout>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validate date range
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date');
    }

    return await repository.getWorkoutsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
```

---

## Data Layer

The Data layer implements the contracts defined in the Domain layer. It handles data persistence, API calls, and data transformation.

### 1. Data Models (Hive)

Data models are separate from domain entities. They handle serialization/deserialization.

#### 1.1 Exercise Model
```dart
// lib/data/models/exercise_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/exercise.dart';

part 'exercise_model.g.dart'; // Generated by Hive

@HiveType(typeId: 1)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final int reps;

  @HiveField(4)
  final double weight;

  @HiveField(5)
  final String? notes;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
  });

  // Convert from domain entity to data model
  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
      notes: exercise.notes,
    );
  }

  // Convert from data model to domain entity
  Exercise toEntity() {
    return Exercise(
      id: id,
      name: name,
      sets: sets,
      reps: reps,
      weight: weight,
      notes: notes,
    );
  }
}
```

#### 1.2 Workout Model
```dart
// lib/data/models/workout_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/workout.dart';
import 'exercise_model.dart';

part 'workout_model.g.dart'; // Generated by Hive

@HiveType(typeId: 0)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<ExerciseModel> exercises;

  @HiveField(3)
  final String? title;

  @HiveField(4)
  final String? notes;

  WorkoutModel({
    required this.id,
    required this.date,
    required this.exercises,
    this.title,
    this.notes,
  });

  // Convert from domain entity to data model
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      date: workout.date,
      exercises: workout.exercises
          .map((exercise) => ExerciseModel.fromEntity(exercise))
          .toList(),
      title: workout.title,
      notes: workout.notes,
    );
  }

  // Convert from data model to domain entity
  Workout toEntity() {
    return Workout(
      id: id,
      date: date,
      exercises: exercises.map((model) => model.toEntity()).toList(),
      title: title,
      notes: notes,
    );
  }
}
```

### 2. Data Sources

Data sources handle the actual data operations (Hive, API, etc.).

#### 2.1 Local Data Source Interface
```dart
// lib/data/datasources/workout_local_datasource.dart

import '../models/workout_model.dart';

abstract class WorkoutLocalDataSource {
  Future<List<WorkoutModel>> getAllWorkouts();
  Future<WorkoutModel?> getWorkoutById(String id);
  Future<void> saveWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
  Future<List<WorkoutModel>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Stream<List<WorkoutModel>> watchAllWorkouts();
}
```

#### 2.2 Hive Local Data Source Implementation
```dart
// lib/data/datasources/workout_local_datasource_impl.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_model.dart';
import 'workout_local_datasource.dart';

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  static const String _boxName = 'workouts';

  Future<Box<WorkoutModel>> get _box async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<WorkoutModel>(_boxName);
    }
    return await Hive.openBox<WorkoutModel>(_boxName);
  }

  @override
  Future<List<WorkoutModel>> getAllWorkouts() async {
    final box = await _box;
    final workouts = box.values.toList();

    // Sort by date, newest first
    workouts.sort((a, b) => b.date.compareTo(a.date));

    return workouts;
  }

  @override
  Future<WorkoutModel?> getWorkoutById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  @override
  Future<void> saveWorkout(WorkoutModel workout) async {
    final box = await _box;
    await box.put(workout.id, workout);
  }

  @override
  Future<void> deleteWorkout(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<List<WorkoutModel>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final box = await _box;
    final allWorkouts = box.values.toList();

    // Filter by date range
    final filteredWorkouts = allWorkouts.where((workout) {
      return workout.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          workout.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Sort by date, newest first
    filteredWorkouts.sort((a, b) => b.date.compareTo(a.date));

    return filteredWorkouts;
  }

  @override
  Stream<List<WorkoutModel>> watchAllWorkouts() async* {
    final box = await _box;

    // Initial emission
    yield box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Watch for changes
    await for (final _ in box.watch()) {
      final workouts = box.values.toList();
      workouts.sort((a, b) => b.date.compareTo(a.date));
      yield workouts;
    }
  }
}
```

### 3. Repository Implementation

The repository implementation bridges the domain and data layers.

#### 3.1 Workout Repository Implementation
```dart
// lib/data/repositories/workout_repository_impl.dart

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_stats.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../models/workout_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl(this.localDataSource);

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final workoutModels = await localDataSource.getAllWorkouts();
    return workoutModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    final workoutModel = await localDataSource.getWorkoutById(id);
    return workoutModel?.toEntity();
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final workoutModels = await localDataSource.getWorkoutsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
    return workoutModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final workoutModel = WorkoutModel.fromEntity(workout);
    await localDataSource.saveWorkout(workoutModel);
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await localDataSource.deleteWorkout(id);
  }

  @override
  Future<double> getTotalVolumeForDate(DateTime date) async {
    final workouts = await getWorkoutsByDateRange(
      startDate: DateTime(date.year, date.month, date.day),
      endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
    return workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
  }

  @override
  Future<WorkoutStats> getWorkoutStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final workouts = await getWorkoutsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final totalVolume = workouts.fold(0.0, (sum, w) => sum + w.totalVolume);
    final totalSets = workouts.fold(0, (sum, w) => sum + w.totalSets);
    final totalExercises = workouts.fold(0, (sum, w) => sum + w.exerciseCount);

    return WorkoutStats(
      totalWorkouts: workouts.length,
      totalVolume: totalVolume,
      totalSets: totalSets,
      totalExercises: totalExercises,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Stream<List<Workout>> watchAllWorkouts() async* {
    await for (final workoutModels in localDataSource.watchAllWorkouts()) {
      yield workoutModels.map((model) => model.toEntity()).toList();
    }
  }
}
```

---

## Presentation Layer

The Presentation layer handles UI and user interactions. It uses Riverpod for state management.

### 1. State Management with Riverpod

#### 1.1 Provider Setup
```dart
// lib/presentation/providers/workout_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/datasources/workout_local_datasource_impl.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/calculate_total_volume.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/get_all_workouts.dart';
import '../../domain/usecases/get_workout_stats.dart';
import '../../domain/usecases/get_workouts_by_date_range.dart';
import '../../domain/usecases/save_workout.dart';

// Data Source Provider
final workoutLocalDataSourceProvider = Provider<WorkoutLocalDataSource>((ref) {
  return WorkoutLocalDataSourceImpl();
});

// Repository Provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final localDataSource = ref.watch(workoutLocalDataSourceProvider);
  return WorkoutRepositoryImpl(localDataSource);
});

// Use Case Providers
final getAllWorkoutsUseCaseProvider = Provider<GetAllWorkouts>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetAllWorkouts(repository);
});

final saveWorkoutUseCaseProvider = Provider<SaveWorkout>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return SaveWorkout(repository);
});

final deleteWorkoutUseCaseProvider = Provider<DeleteWorkout>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return DeleteWorkout(repository);
});

final getWorkoutStatsUseCaseProvider = Provider<GetWorkoutStats>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetWorkoutStats(repository);
});

final getWorkoutsByDateRangeUseCaseProvider = Provider<GetWorkoutsByDateRange>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetWorkoutsByDateRange(repository);
});

final calculateTotalVolumeUseCaseProvider = Provider<CalculateTotalVolume>((ref) {
  return CalculateTotalVolume();
});

// Stream Provider for all workouts (real-time updates)
final workoutsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.watchAllWorkouts();
});

// FutureProvider for workout stats (last 30 days)
final workoutStatsProvider = FutureProvider((ref) {
  final useCase = ref.watch(getWorkoutStatsUseCaseProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  return useCase(startDate: startDate, endDate: endDate);
});
```

#### 1.2 Workout List State Notifier
```dart
// lib/presentation/providers/workout_list_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/get_all_workouts.dart';

class WorkoutListState {
  final List<Workout> workouts;
  final bool isLoading;
  final String? errorMessage;

  const WorkoutListState({
    this.workouts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WorkoutListState copyWith({
    List<Workout>? workouts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkoutListState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WorkoutListNotifier extends StateNotifier<WorkoutListState> {
  final GetAllWorkouts getAllWorkoutsUseCase;
  final DeleteWorkout deleteWorkoutUseCase;

  WorkoutListNotifier({
    required this.getAllWorkoutsUseCase,
    required this.deleteWorkoutUseCase,
  }) : super(const WorkoutListState()) {
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final workouts = await getAllWorkoutsUseCase();
      state = state.copyWith(workouts: workouts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load workouts: $e',
      );
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await deleteWorkoutUseCase(workoutId);
      await loadWorkouts(); // Reload after deletion
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete workout: $e');
    }
  }
}

// Provider for WorkoutListNotifier
final workoutListNotifierProvider =
    StateNotifierProvider<WorkoutListNotifier, WorkoutListState>((ref) {
  return WorkoutListNotifier(
    getAllWorkoutsUseCase: ref.watch(getAllWorkoutsUseCaseProvider),
    deleteWorkoutUseCase: ref.watch(deleteWorkoutUseCaseProvider),
  );
});
```

#### 1.3 Workout Form State Notifier
```dart
// lib/presentation/providers/workout_form_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../domain/usecases/save_workout.dart';

class WorkoutFormState {
  final String? workoutId;
  final DateTime date;
  final String? title;
  final String? notes;
  final List<Exercise> exercises;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  const WorkoutFormState({
    this.workoutId,
    required this.date,
    this.title,
    this.notes,
    this.exercises = const [],
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  WorkoutFormState copyWith({
    String? workoutId,
    DateTime? date,
    String? title,
    String? notes,
    List<Exercise>? exercises,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return WorkoutFormState(
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
  }
}

class WorkoutFormNotifier extends StateNotifier<WorkoutFormState> {
  final SaveWorkout saveWorkoutUseCase;

  WorkoutFormNotifier({
    required this.saveWorkoutUseCase,
    Workout? initialWorkout,
  }) : super(WorkoutFormState(
          workoutId: initialWorkout?.id,
          date: initialWorkout?.date ?? DateTime.now(),
          title: initialWorkout?.title,
          notes: initialWorkout?.notes,
          exercises: initialWorkout?.exercises ?? [],
        ));

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setTitle(String? title) {
    state = state.copyWith(title: title);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void addExercise(Exercise exercise) {
    state = state.copyWith(
      exercises: [...state.exercises, exercise],
    );
  }

  void updateExercise(int index, Exercise exercise) {
    final updatedExercises = List<Exercise>.from(state.exercises);
    updatedExercises[index] = exercise;
    state = state.copyWith(exercises: updatedExercises);
  }

  void removeExercise(int index) {
    final updatedExercises = List<Exercise>.from(state.exercises);
    updatedExercises.removeAt(index);
    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> saveWorkout() async {
    if (state.exercises.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please add at least one exercise',
      );
      return;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final workout = Workout(
        id: state.workoutId ?? const Uuid().v4(),
        date: state.date,
        title: state.title,
        notes: state.notes,
        exercises: state.exercises,
      );

      await saveWorkoutUseCase(workout);
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save workout: $e',
      );
    }
  }
}

// Provider factory for WorkoutFormNotifier
final workoutFormNotifierProvider = StateNotifierProvider.family<
    WorkoutFormNotifier,
    WorkoutFormState,
    Workout?>((ref, initialWorkout) {
  return WorkoutFormNotifier(
    saveWorkoutUseCase: ref.watch(saveWorkoutUseCaseProvider),
    initialWorkout: initialWorkout,
  );
});
```

### 2. Screens

#### 2.1 Screen Structure

```
screens/
├── home_screen.dart           - Main screen with workout list
├── workout_detail_screen.dart - View single workout details
├── workout_form_screen.dart   - Add/Edit workout
├── exercise_form_screen.dart  - Add/Edit exercise
└── statistics_screen.dart     - View workout statistics
```

#### 2.2 Home Screen (Workout List)
```dart
// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import 'workout_detail_screen.dart';
import 'workout_form_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: workoutsAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return const Center(
              child: Text('No workouts yet. Add your first workout!'),
            );
          }

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(
                    workout.title ?? 'Workout',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_formatDate(workout.date)}\n'
                    '${workout.exerciseCount} exercises • '
                    '${workout.totalVolume.toStringAsFixed(0)} kg total volume',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: workout),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WorkoutFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

#### 2.3 Workout Detail Screen
```dart
// lib/presentation/screens/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_providers.dart';
import 'workout_form_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title ?? 'Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutFormScreen(
                    existingWorkout: workout,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Workout'),
                  content: const Text(
                    'Are you sure you want to delete this workout?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final deleteUseCase = ref.read(deleteWorkoutUseCaseProvider);
                await deleteUseCase(workout.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            _InfoCard(
              title: 'Date',
              content: _formatDate(workout.date),
            ),
            const SizedBox(height: 16),

            // Statistics
            _InfoCard(
              title: 'Statistics',
              content: '${workout.exerciseCount} exercises\n'
                  '${workout.totalSets} total sets\n'
                  '${workout.totalVolume.toStringAsFixed(1)} kg total volume',
            ),
            const SizedBox(height: 16),

            // Notes
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              _InfoCard(
                title: 'Notes',
                content: workout.notes!,
              ),
              const SizedBox(height: 16),
            ],

            // Exercises
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...workout.exercises.map((exercise) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight} kg',
                      ),
                      Text(
                        'Volume: ${exercise.volume.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (exercise.notes != null &&
                          exercise.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${exercise.notes}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
```

#### 2.4 Workout Form Screen
```dart
// lib/presentation/screens/workout_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_form_notifier.dart';
import 'exercise_form_screen.dart';

class WorkoutFormScreen extends ConsumerWidget {
  final Workout? existingWorkout;

  const WorkoutFormScreen({
    super.key,
    this.existingWorkout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotifier = ref.watch(
      workoutFormNotifierProvider(existingWorkout).notifier,
    );
    final formState = ref.watch(
      workoutFormNotifierProvider(existingWorkout),
    );

    // Listen for save success
    ref.listen(
      workoutFormNotifierProvider(existingWorkout),
      (previous, next) {
        if (next.saveSuccess) {
          Navigator.pop(context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(existingWorkout == null ? 'New Workout' : 'Edit Workout'),
        actions: [
          if (formState.isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                formNotifier.saveWorkout();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (formState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formState.errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Date picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text(_formatDate(formState.date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: formState.date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  formNotifier.setDate(date);
                }
              },
            ),
            const Divider(),

            // Title
            TextField(
              decoration: const InputDecoration(
                labelText: 'Workout Title (Optional)',
                hintText: 'e.g., Upper Body Day',
              ),
              controller: TextEditingController(text: formState.title)
                ..selection = TextSelection.collapsed(
                  offset: formState.title?.length ?? 0,
                ),
              onChanged: (value) {
                formNotifier.setTitle(value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes...',
              ),
              maxLines: 3,
              controller: TextEditingController(text: formState.notes)
                ..selection = TextSelection.collapsed(
                  offset: formState.notes?.length ?? 0,
                ),
              onChanged: (value) {
                formNotifier.setNotes(value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 24),

            // Total volume
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Volume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${formState.totalVolume.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercises header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final exercise = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseFormScreen(),
                      ),
                    );
                    if (exercise != null) {
                      formNotifier.addExercise(exercise);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Exercise list
            if (formState.exercises.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No exercises added yet'),
                  ),
                ),
              )
            else
              ...formState.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${exercise.sets} × ${exercise.reps} @ ${exercise.weight} kg',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updatedExercise = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseFormScreen(
                                  existingExercise: exercise,
                                ),
                              ),
                            );
                            if (updatedExercise != null) {
                              formNotifier.updateExercise(
                                index,
                                updatedExercise,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            formNotifier.removeExercise(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

#### 2.5 Exercise Form Screen
```dart
// lib/presentation/screens/exercise_form_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? existingExercise;

  const ExerciseFormScreen({
    super.key,
    this.existingExercise,
  });

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingExercise?.name,
    );
    _setsController = TextEditingController(
      text: widget.existingExercise?.sets.toString(),
    );
    _repsController = TextEditingController(
      text: widget.existingExercise?.reps.toString(),
    );
    _weightController = TextEditingController(
      text: widget.existingExercise?.weight.toString(),
    );
    _notesController = TextEditingController(
      text: widget.existingExercise?.notes,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        id: widget.existingExercise?.id ?? const Uuid().v4(),
        name: _nameController.text,
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        weight: double.parse(_weightController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Navigator.pop(context, exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExercise == null ? 'Add Exercise' : 'Edit Exercise',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Bench Press',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _setsController,
              decoration: const InputDecoration(
                labelText: 'Sets',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of sets';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of reps';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter weight';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any notes about this exercise...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 2.6 Statistics Screen
```dart
// lib/presentation/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(
                title: 'Total Workouts',
                value: stats.totalWorkouts.toString(),
                icon: Icons.fitness_center,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Total Volume',
                value: '${stats.totalVolume.toStringAsFixed(0)} kg',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Average Volume per Workout',
                value: '${stats.averageVolumePerWorkout.toStringAsFixed(0)} kg',
                icon: Icons.bar_chart,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Total Sets',
                value: stats.totalSets.toString(),
                icon: Icons.list,
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Total Exercises',
                value: stats.totalExercises.toString(),
                icon: Icons.format_list_numbered,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Period',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last 30 days\n'
                        '${_formatDate(stats.startDate)} - ${_formatDate(stats.endDate)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading statistics: $error'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Dependency Flow

The dependency rule ensures that dependencies only point inward:

```
┌─────────────────────────────────────┐
│  Presentation Layer                 │
│  ├─ Screens                         │
│  ├─ Widgets                         │
│  └─ Providers (Riverpod)            │
│      │                               │
│      └─► depends on Use Cases       │
└─────────────────────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  Data Layer                         │
│  ├─ Repository Implementations      │
│  ├─ Data Sources                    │
│  └─ Data Models (Hive)              │
│      │                               │
│      └─► implements Repository      │
│          interfaces                 │
└─────────────────────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  Domain Layer                       │
│  ├─ Entities (pure Dart)            │
│  ├─ Repository Interfaces           │
│  └─ Use Cases                       │
│                                      │
│  NO DEPENDENCIES ON OUTER LAYERS    │
└─────────────────────────────────────┘
```

**Key Points:**
- Presentation depends on Domain (use cases, entities)
- Data depends on Domain (implements repository interfaces)
- Domain is independent (no external dependencies)
- Data Models convert to/from Domain Entities
- Repository implementations bridge Data and Domain

---

## Riverpod Provider Architecture

### Provider Hierarchy

```
┌──────────────────────────────────────────────┐
│           Infrastructure Providers           │
│  - workoutLocalDataSourceProvider            │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│          Repository Providers                │
│  - workoutRepositoryProvider                 │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│           Use Case Providers                 │
│  - getAllWorkoutsUseCaseProvider             │
│  - saveWorkoutUseCaseProvider                │
│  - deleteWorkoutUseCaseProvider              │
│  - getWorkoutStatsUseCaseProvider            │
│  - etc.                                      │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│      State Management Providers              │
│  - workoutsStreamProvider                    │
│  - workoutStatsProvider                      │
│  - workoutListNotifierProvider               │
│  - workoutFormNotifierProvider               │
└──────────────────────────────────────────────┘
```

### Provider Types Used

1. **Provider**: For dependencies (repositories, use cases)
2. **StateNotifierProvider**: For mutable state with actions
3. **StreamProvider**: For real-time data from Hive
4. **FutureProvider**: For async data loading (stats)
5. **Family Modifier**: For parameterized providers (workout form)

---

## Complete Folder Structure

```
lib/
├── main.dart
│
├── domain/
│   ├── entities/
│   │   ├── exercise.dart
│   │   ├── workout.dart
│   │   └── workout_stats.dart
│   │
│   ├── repositories/
│   │   └── workout_repository.dart
│   │
│   └── usecases/
│       ├── calculate_total_volume.dart
│       ├── delete_workout.dart
│       ├── get_all_workouts.dart
│       ├── get_workout_stats.dart
│       ├── get_workouts_by_date_range.dart
│       └── save_workout.dart
│
├── data/
│   ├── models/
│   │   ├── exercise_model.dart
│   │   ├── exercise_model.g.dart         # Generated by Hive
│   │   ├── workout_model.dart
│   │   └── workout_model.g.dart          # Generated by Hive
│   │
│   ├── datasources/
│   │   ├── workout_local_datasource.dart
│   │   └── workout_local_datasource_impl.dart
│   │
│   └── repositories/
│       └── workout_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── workout_providers.dart
    │   ├── workout_list_notifier.dart
    │   └── workout_form_notifier.dart
    │
    ├── screens/
    │   ├── home_screen.dart
    │   ├── workout_detail_screen.dart
    │   ├── workout_form_screen.dart
    │   ├── exercise_form_screen.dart
    │   └── statistics_screen.dart
    │
    └── widgets/
        └── (shared widgets as needed)
```

---

## Implementation Rationale

### Why Domain-First?

1. **Business Logic Independence**: Domain entities and use cases are pure Dart, testable without Flutter
2. **Flexibility**: Can swap UI frameworks, databases, or APIs without touching business logic
3. **Testability**: Easy to unit test domain logic in isolation
4. **Clarity**: Business requirements are explicit in code structure

### Why Separate Entities and Models?

- **Entities**: Pure business objects, no framework dependencies
- **Models**: Framework-specific (Hive annotations), handle serialization
- **Separation**: Allows changing persistence layer without affecting business logic

### Why Use Cases?

- Each use case represents a single business operation
- Easy to test in isolation
- Clear entry points for business logic
- Prevents bloated repository classes

### Why Riverpod?

- Compile-safe dependency injection
- Easy to test (can override providers)
- Type-safe state management
- Built-in support for async operations
- No BuildContext required for business logic

### Why Repository Pattern?

- Abstracts data source details
- Easy to add multiple data sources (local + remote)
- Allows switching implementations
- Clear contract between layers

---

## Required Packages

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UUID Generation
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  hive_generator: ^2.0.1
  build_runner: ^2.4.8

  # Testing
  mockito: ^5.4.4
```

---

## Next Steps for Implementation

1. **Initialize Hive**:
   ```dart
   // In main.dart
   await Hive.initFlutter();
   Hive.registerAdapter(WorkoutModelAdapter());
   Hive.registerAdapter(ExerciseModelAdapter());
   ```

2. **Generate Hive Adapters**:
   ```bash
   flutter pub run build_runner build
   ```

3. **Set up Riverpod**:
   ```dart
   // In main.dart
   runApp(
     ProviderScope(
       child: MyApp(),
     ),
   );
   ```

4. **Implement Domain Layer First** (entities, interfaces, use cases)
5. **Implement Data Layer** (models, data sources, repositories)
6. **Implement Presentation Layer** (providers, screens)

---

## Testing Strategy

### Domain Layer Tests
- Unit test entities (volume calculations, equality)
- Unit test use cases with mock repositories
- No framework dependencies needed

### Data Layer Tests
- Test repository implementations with mock data sources
- Test data model conversions (entity ↔ model)
- Integration tests with actual Hive database

### Presentation Layer Tests
- Widget tests for screens
- Provider tests with overridden dependencies
- Integration tests for complete user flows

---

## Summary

This architecture provides:

- **Clear Separation**: Three distinct layers with well-defined responsibilities
- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code
- **Type Safety**: Riverpod and strong typing throughout
- **Business Logic Protection**: Domain layer is pure and independent

The Domain-First approach ensures that business requirements drive the architecture, not framework constraints.
