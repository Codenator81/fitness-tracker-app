import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_tracker/data/repositories/workout_repository_impl.dart';
import 'package:fitness_tracker/data/datasources/workout_local_datasource.dart';
import 'package:fitness_tracker/data/models/workout_model.dart';
import 'package:fitness_tracker/domain/entities/workout.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';
import 'package:fitness_tracker/domain/exceptions/workout_exceptions.dart';

// Mock classes
class MockWorkoutLocalDataSource extends Mock implements WorkoutLocalDataSource {}

void main() {
  late WorkoutRepositoryImpl repository;
  late MockWorkoutLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWorkoutLocalDataSource();
    repository = WorkoutRepositoryImpl(mockDataSource);
  });

  // Test fixtures
  final testDate = DateTime(2024, 1, 15);

  const testExercise = Exercise(
    id: '1',
    name: 'Bench Press',
    sets: 3,
    reps: 10,
    weight: 50.0,
  );

  final testWorkout = Workout(
    id: '1',
    name: 'Upper Body Day',
    date: testDate,
    exercises: const [testExercise],
    duration: const Duration(minutes: 45),
    notes: 'Great session',
  );

  final testWorkoutModel = WorkoutModel.fromEntity(testWorkout);

  // Register fallback values for any() matchers
  setUpAll(() {
    registerFallbackValue(testWorkoutModel);
  });

  group('WorkoutRepositoryImpl Tests', () {
    group('saveWorkout', () {
      test('should convert entity to model and call data source', () async {
        // Arrange
        when(() => mockDataSource.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.saveWorkout(testWorkout);

        // Assert
        verify(() => mockDataSource.saveWorkout(any(
          that: predicate<WorkoutModel>((model) =>
              model.id == testWorkout.id &&
              model.name == testWorkout.name &&
              model.exercises.length == testWorkout.exercises.length),
        ))).called(1);
      });

      test('should successfully save workout without optional fields', () async {
        // Arrange
        final minimalWorkout = Workout(
          id: '2',
          date: testDate,
          exercises: const [testExercise],
        );

        when(() => mockDataSource.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.saveWorkout(minimalWorkout);

        // Assert
        verify(() => mockDataSource.saveWorkout(any())).called(1);
      });

      test('should throw WorkoutStorageException when data source fails', () async {
        // Arrange
        when(() => mockDataSource.saveWorkout(any()))
            .thenThrow(DataSourceException('Database error'));

        // Act & Assert
        expect(
          () => repository.saveWorkout(testWorkout),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should include error message in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.saveWorkout(any()))
            .thenThrow(DataSourceException('Disk full'));

        // Act & Assert
        expect(
          () => repository.saveWorkout(testWorkout),
          throwsA(
            predicate<WorkoutStorageException>(
              (e) => e.message.contains('Failed to save workout'),
            ),
          ),
        );
      });

      test('should handle data source throwing non-DataSourceException', () async {
        // Arrange
        when(() => mockDataSource.saveWorkout(any()))
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => repository.saveWorkout(testWorkout),
          throwsA(isA<WorkoutStorageException>()),
        );
      });
    });

    group('getWorkoutById', () {
      test('should call data source and convert model to entity', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenAnswer((_) async => testWorkoutModel);

        // Act
        final result = await repository.getWorkoutById('1');

        // Assert
        verify(() => mockDataSource.getWorkout('1')).called(1);
        expect(result, isNotNull);
        expect(result?.id, testWorkout.id);
        expect(result?.name, testWorkout.name);
        expect(result?.exercises.length, testWorkout.exercises.length);
      });

      test('should return null when workout is not found', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getWorkoutById('999');

        // Assert
        verify(() => mockDataSource.getWorkout('999')).called(1);
        expect(result, isNull);
      });

      test('should throw WorkoutStorageException when data source fails', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenThrow(DataSourceException('Database error'));

        // Act & Assert
        expect(
          () => repository.getWorkoutById('1'),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should include error message in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenThrow(DataSourceException('Connection lost'));

        // Act & Assert
        expect(
          () => repository.getWorkoutById('1'),
          throwsA(
            predicate<WorkoutStorageException>(
              (e) => e.message.contains('Failed to get workout by ID'),
            ),
          ),
        );
      });

      test('should properly convert model with all fields', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenAnswer((_) async => testWorkoutModel);

        // Act
        final result = await repository.getWorkoutById('1');

        // Assert
        expect(result?.id, testWorkout.id);
        expect(result?.name, testWorkout.name);
        expect(result?.date, testWorkout.date);
        expect(result?.duration, testWorkout.duration);
        expect(result?.notes, testWorkout.notes);
      });
    });

    group('getAllWorkouts', () {
      test('should call data source and convert all models to entities', () async {
        // Arrange
        const exercise2 = Exercise(
          id: '2',
          name: 'Squat',
          sets: 4,
          reps: 8,
          weight: 100.0,
        );

        final workout2 = Workout(
          id: '2',
          name: 'Leg Day',
          date: testDate,
          exercises: const [exercise2],
        );

        final workoutModel2 = WorkoutModel.fromEntity(workout2);

        when(() => mockDataSource.getAllWorkouts())
            .thenAnswer((_) async => [testWorkoutModel, workoutModel2]);

        // Act
        final result = await repository.getAllWorkouts();

        // Assert
        verify(() => mockDataSource.getAllWorkouts()).called(1);
        expect(result.length, 2);
        expect(result[0].id, testWorkout.id);
        expect(result[1].id, workout2.id);
      });

      test('should return empty list when no workouts exist', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllWorkouts();

        // Assert
        verify(() => mockDataSource.getAllWorkouts()).called(1);
        expect(result, isEmpty);
      });

      test('should throw WorkoutStorageException when data source fails', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenThrow(DataSourceException('Database error'));

        // Act & Assert
        expect(
          () => repository.getAllWorkouts(),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should include error message in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenThrow(DataSourceException('Read error'));

        // Act & Assert
        expect(
          () => repository.getAllWorkouts(),
          throwsA(
            predicate<WorkoutStorageException>(
              (e) => e.message.contains('Failed to get all workouts'),
            ),
          ),
        );
      });

      test('should handle large number of workouts', () async {
        // Arrange
        final manyWorkouts = List.generate(
          100,
          (i) => WorkoutModel.fromEntity(
            Workout(
              id: '$i',
              date: testDate,
              exercises: const [testExercise],
            ),
          ),
        );

        when(() => mockDataSource.getAllWorkouts())
            .thenAnswer((_) async => manyWorkouts);

        // Act
        final result = await repository.getAllWorkouts();

        // Assert
        expect(result.length, 100);
      });

      test('should properly convert all fields for each workout', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenAnswer((_) async => [testWorkoutModel]);

        // Act
        final result = await repository.getAllWorkouts();

        // Assert
        final workout = result.first;
        expect(workout.id, testWorkout.id);
        expect(workout.name, testWorkout.name);
        expect(workout.date, testWorkout.date);
        expect(workout.exercises.length, testWorkout.exercises.length);
        expect(workout.duration, testWorkout.duration);
        expect(workout.notes, testWorkout.notes);
      });
    });

    group('deleteWorkout', () {
      test('should call data source with correct ID', () async {
        // Arrange
        when(() => mockDataSource.deleteWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteWorkout('1');

        // Assert
        verify(() => mockDataSource.deleteWorkout('1')).called(1);
      });

      test('should successfully delete non-existent workout', () async {
        // Arrange
        when(() => mockDataSource.deleteWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteWorkout('999');

        // Assert
        verify(() => mockDataSource.deleteWorkout('999')).called(1);
      });

      test('should throw WorkoutStorageException when data source fails', () async {
        // Arrange
        when(() => mockDataSource.deleteWorkout(any()))
            .thenThrow(DataSourceException('Database error'));

        // Act & Assert
        expect(
          () => repository.deleteWorkout('1'),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should include error message in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.deleteWorkout(any()))
            .thenThrow(DataSourceException('Delete failed'));

        // Act & Assert
        expect(
          () => repository.deleteWorkout('1'),
          throwsA(
            predicate<WorkoutStorageException>(
              (e) => e.message.contains('Failed to delete workout'),
            ),
          ),
        );
      });

      test('should handle special characters in ID', () async {
        // Arrange
        when(() => mockDataSource.deleteWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteWorkout('id-with-special-chars-!@#');

        // Assert
        verify(() => mockDataSource.deleteWorkout('id-with-special-chars-!@#'))
            .called(1);
      });
    });

    group('updateWorkout', () {
      test('should convert entity to model and call data source', () async {
        // Arrange
        when(() => mockDataSource.updateWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateWorkout(testWorkout);

        // Assert
        verify(() => mockDataSource.updateWorkout(any(
          that: predicate<WorkoutModel>((model) =>
              model.id == testWorkout.id &&
              model.name == testWorkout.name &&
              model.exercises.length == testWorkout.exercises.length),
        ))).called(1);
      });

      test('should successfully update workout without optional fields', () async {
        // Arrange
        final minimalWorkout = Workout(
          id: '2',
          date: testDate,
          exercises: const [testExercise],
        );

        when(() => mockDataSource.updateWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateWorkout(minimalWorkout);

        // Assert
        verify(() => mockDataSource.updateWorkout(any())).called(1);
      });

      test('should throw WorkoutStorageException when data source fails', () async {
        // Arrange
        when(() => mockDataSource.updateWorkout(any()))
            .thenThrow(DataSourceException('Database error'));

        // Act & Assert
        expect(
          () => repository.updateWorkout(testWorkout),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should include error message in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.updateWorkout(any()))
            .thenThrow(DataSourceException('Update failed'));

        // Act & Assert
        expect(
          () => repository.updateWorkout(testWorkout),
          throwsA(
            predicate<WorkoutStorageException>(
              (e) => e.message.contains('Failed to update workout'),
            ),
          ),
        );
      });

      test('should handle updating workout with modified exercises', () async {
        // Arrange
        const newExercise = Exercise(
          id: '3',
          name: 'Deadlift',
          sets: 3,
          reps: 5,
          weight: 120.0,
        );

        final updatedWorkout = testWorkout.copyWith(
          exercises: [testExercise, newExercise],
        );

        when(() => mockDataSource.updateWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateWorkout(updatedWorkout);

        // Assert
        verify(() => mockDataSource.updateWorkout(any(
          that: predicate<WorkoutModel>(
            (model) => model.exercises.length == 2,
          ),
        ))).called(1);
      });
    });

    group('error handling', () {
      test('should wrap all DataSourceExceptions in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenThrow(DataSourceException('Test error'));

        // Act & Assert
        expect(
          () => repository.getAllWorkouts(),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('should wrap generic exceptions in WorkoutStorageException', () async {
        // Arrange
        when(() => mockDataSource.getAllWorkouts())
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => repository.getAllWorkouts(),
          throwsA(isA<WorkoutStorageException>()),
        );
      });

      test('WorkoutStorageException should have proper toString', () {
        // Arrange
        final exception = WorkoutStorageException('Test error');

        // Act
        final string = exception.toString();

        // Assert
        expect(string, contains('WorkoutStorageException'));
        expect(string, contains('Test error'));
      });
    });

    group('data conversion integrity', () {
      test('should maintain data integrity during save round-trip', () async {
        // Arrange
        WorkoutModel? capturedModel;
        when(() => mockDataSource.saveWorkout(any())).thenAnswer((invocation) {
          capturedModel = invocation.positionalArguments[0] as WorkoutModel;
          return Future.value();
        });

        // Act
        await repository.saveWorkout(testWorkout);

        // Assert
        expect(capturedModel, isNotNull);
        final entity = capturedModel!.toEntity();
        expect(entity.id, testWorkout.id);
        expect(entity.name, testWorkout.name);
        expect(entity.date, testWorkout.date);
        expect(entity.exercises.length, testWorkout.exercises.length);
      });

      test('should maintain data integrity during update round-trip', () async {
        // Arrange
        WorkoutModel? capturedModel;
        when(() => mockDataSource.updateWorkout(any())).thenAnswer((invocation) {
          capturedModel = invocation.positionalArguments[0] as WorkoutModel;
          return Future.value();
        });

        // Act
        await repository.updateWorkout(testWorkout);

        // Assert
        expect(capturedModel, isNotNull);
        final entity = capturedModel!.toEntity();
        expect(entity.id, testWorkout.id);
        expect(entity.name, testWorkout.name);
        expect(entity.exercises.length, testWorkout.exercises.length);
        expect(entity.duration, testWorkout.duration);
        expect(entity.notes, testWorkout.notes);
      });

      test('should maintain data integrity when retrieving workout', () async {
        // Arrange
        when(() => mockDataSource.getWorkout(any()))
            .thenAnswer((_) async => testWorkoutModel);

        // Act
        final result = await repository.getWorkoutById('1');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, testWorkout.id);
        expect(result?.name, testWorkout.name);
        expect(result?.date, testWorkout.date);
        expect(result?.exercises.first.name, testWorkout.exercises.first.name);
        expect(result?.duration, testWorkout.duration);
        expect(result?.notes, testWorkout.notes);
      });
    });
  });
}
