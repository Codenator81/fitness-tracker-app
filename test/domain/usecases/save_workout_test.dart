import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_tracker/domain/entities/workout.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';
import 'package:fitness_tracker/domain/repositories/workout_repository.dart';
import 'package:fitness_tracker/domain/usecases/save_workout.dart';
import 'package:fitness_tracker/domain/exceptions/workout_exceptions.dart';

// Mock classes
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late SaveWorkout useCase;
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
    useCase = SaveWorkout(mockRepository);
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

  final validWorkout = Workout(
    id: '1',
    name: 'Upper Body Day',
    date: testDate,
    exercises: const [testExercise],
    duration: const Duration(minutes: 45),
    notes: 'Great session',
  );

  // Register fallback values for any() matchers
  setUpAll(() {
    registerFallbackValue(validWorkout);
  });

  group('SaveWorkout Use Case Tests', () {
    group('successful save', () {
      test('should save workout when it contains at least one exercise', () async {
        // Arrange
        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(validWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(validWorkout)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should save workout with multiple exercises', () async {
        // Arrange
        const exercise2 = Exercise(
          id: '2',
          name: 'Squat',
          sets: 4,
          reps: 8,
          weight: 100.0,
        );

        final workoutWithMultipleExercises = Workout(
          id: '2',
          date: testDate,
          exercises: const [testExercise, exercise2],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(workoutWithMultipleExercises);

        // Assert
        verify(() => mockRepository.saveWorkout(workoutWithMultipleExercises))
            .called(1);
      });

      test('should save workout without optional fields', () async {
        // Arrange
        final minimalWorkout = Workout(
          id: '3',
          date: testDate,
          exercises: const [testExercise],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(minimalWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(minimalWorkout)).called(1);
      });
    });

    group('validation failures', () {
      test('should throw WorkoutValidationException when workout has no exercises', () async {
        // Arrange
        final emptyWorkout = Workout(
          id: '4',
          name: 'Empty Workout',
          date: testDate,
          exercises: const [],
        );

        // Act & Assert
        expect(
          () => useCase(emptyWorkout),
          throwsA(isA<WorkoutValidationException>()),
        );

        // Verify repository was never called
        verifyNever(() => mockRepository.saveWorkout(any()));
      });

      test('should throw exception with correct message for empty exercises', () async {
        // Arrange
        final emptyWorkout = Workout(
          id: '5',
          date: testDate,
          exercises: const [],
        );

        // Act & Assert
        expect(
          () => useCase(emptyWorkout),
          throwsA(
            predicate<WorkoutValidationException>(
              (e) => e.message == 'Workout must contain at least one exercise',
            ),
          ),
        );
      });

      test('should not save workout when validation fails', () async {
        // Arrange
        final emptyWorkout = Workout(
          id: '6',
          date: testDate,
          exercises: const [],
        );

        // Act
        try {
          await useCase(emptyWorkout);
        } catch (e) {
          // Exception expected
        }

        // Assert
        verifyNever(() => mockRepository.saveWorkout(any()));
      });
    });

    group('repository error handling', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        when(() => mockRepository.saveWorkout(any()))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => useCase(validWorkout),
          throwsA(isA<Exception>()),
        );
      });

      test('should call repository exactly once even if it throws', () async {
        // Arrange
        when(() => mockRepository.saveWorkout(any()))
            .thenThrow(Exception('Database error'));

        // Act
        try {
          await useCase(validWorkout);
        } catch (e) {
          // Exception expected
        }

        // Assert
        verify(() => mockRepository.saveWorkout(validWorkout)).called(1);
      });
    });

    group('edge cases', () {
      test('should save workout with very long name', () async {
        // Arrange
        final longNameWorkout = Workout(
          id: '7',
          name: 'A' * 1000, // Very long name
          date: testDate,
          exercises: const [testExercise],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(longNameWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(longNameWorkout)).called(1);
      });

      test('should save workout with very long notes', () async {
        // Arrange
        final longNotesWorkout = Workout(
          id: '8',
          date: testDate,
          exercises: const [testExercise],
          notes: 'N' * 5000, // Very long notes
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(longNotesWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(longNotesWorkout)).called(1);
      });

      test('should save workout with future date', () async {
        // Arrange
        final futureWorkout = Workout(
          id: '9',
          date: DateTime(2025, 12, 31),
          exercises: const [testExercise],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(futureWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(futureWorkout)).called(1);
      });

      test('should save workout with very old date', () async {
        // Arrange
        final oldWorkout = Workout(
          id: '10',
          date: DateTime(2000, 1, 1),
          exercises: const [testExercise],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(oldWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(oldWorkout)).called(1);
      });

      test('should save workout with zero duration', () async {
        // Arrange
        final zeroDurationWorkout = Workout(
          id: '11',
          date: testDate,
          exercises: const [testExercise],
          duration: Duration.zero,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(zeroDurationWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(zeroDurationWorkout)).called(1);
      });

      test('should save workout with very long duration', () async {
        // Arrange
        final longDurationWorkout = Workout(
          id: '12',
          date: testDate,
          exercises: const [testExercise],
          duration: const Duration(hours: 10),
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(longDurationWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(longDurationWorkout)).called(1);
      });
    });

    group('business logic validation', () {
      test('should validate before calling repository', () async {
        // Arrange
        final emptyWorkout = Workout(
          id: '13',
          date: testDate,
          exercises: const [],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        try {
          await useCase(emptyWorkout);
        } catch (e) {
          // Exception expected
        }

        // Assert - repository should never be called due to validation failure
        verifyNever(() => mockRepository.saveWorkout(any()));
      });

      test('should allow workout with single exercise', () async {
        // Arrange
        final singleExerciseWorkout = Workout(
          id: '14',
          date: testDate,
          exercises: const [testExercise],
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(singleExerciseWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(singleExerciseWorkout))
            .called(1);
      });

      test('should allow workout with 10+ exercises', () async {
        // Arrange
        final manyExercises = List.generate(
          15,
          (i) => Exercise(
            id: '$i',
            name: 'Exercise $i',
            sets: 3,
            reps: 10,
            weight: 50.0,
          ),
        );

        final manyExercisesWorkout = Workout(
          id: '15',
          date: testDate,
          exercises: manyExercises,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase(manyExercisesWorkout);

        // Assert
        verify(() => mockRepository.saveWorkout(manyExercisesWorkout))
            .called(1);
      });
    });
  });
}
