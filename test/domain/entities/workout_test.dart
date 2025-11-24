import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/domain/entities/workout.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';

void main() {
  group('Workout Entity Tests', () {
    // Test fixtures
    const exercise1 = Exercise(
      id: '1',
      name: 'Bench Press',
      sets: 3,
      reps: 10,
      weight: 50.0,
    );

    const exercise2 = Exercise(
      id: '2',
      name: 'Squat',
      sets: 4,
      reps: 8,
      weight: 100.0,
    );

    const exercise3 = Exercise(
      id: '3',
      name: 'Deadlift',
      sets: 3,
      reps: 5,
      weight: 120.0,
    );

    test('should create workout with all fields', () {
      // Arrange & Act
      final workout = Workout(
        id: '1',
        name: 'Upper Body Day',
        date: DateTime(2024, 1, 15),
        exercises: const [exercise1],
        duration: const Duration(minutes: 45),
        notes: 'Great session',
      );

      // Assert
      expect(workout.id, '1');
      expect(workout.name, 'Upper Body Day');
      expect(workout.date, DateTime(2024, 1, 15));
      expect(workout.exercises.length, 1);
      expect(workout.duration, const Duration(minutes: 45));
      expect(workout.notes, 'Great session');
    });

    test('should create workout without optional fields', () {
      // Arrange & Act
      final workout = Workout(
        id: '1',
        date: DateTime(2024, 1, 15),
        exercises: const [exercise1],
      );

      // Assert
      expect(workout.name, null);
      expect(workout.duration, null);
      expect(workout.notes, null);
    });

    test('should create workout with empty exercise list', () {
      // Arrange & Act
      final workout = Workout(
        id: '1',
        date: DateTime(2024, 1, 15),
        exercises: const [],
      );

      // Assert
      expect(workout.exercises, isEmpty);
      expect(workout.exerciseCount, 0);
    });

    group('totalVolume calculation', () {
      test('should calculate total volume for single exercise', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final volume = workout.totalVolume;

        // Assert
        expect(volume, 1500.0); // 3 * 10 * 50 = 1500
      });

      test('should calculate total volume for multiple exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2, exercise3],
        );

        // Act
        final volume = workout.totalVolume;

        // Assert
        // exercise1: 3 * 10 * 50 = 1500
        // exercise2: 4 * 8 * 100 = 3200
        // exercise3: 3 * 5 * 120 = 1800
        // Total: 6500
        expect(volume, 6500.0);
      });

      test('should return zero for workout with no exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [],
        );

        // Act
        final volume = workout.totalVolume;

        // Assert
        expect(volume, 0.0);
      });

      test('should handle exercises with zero weight', () {
        // Arrange
        const bodyweightExercise = Exercise(
          id: '4',
          name: 'Push-ups',
          sets: 3,
          reps: 20,
          weight: 0.0,
        );

        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, bodyweightExercise],
        );

        // Act
        final volume = workout.totalVolume;

        // Assert
        expect(volume, 1500.0); // Only counts exercise1
      });
    });

    group('totalSets calculation', () {
      test('should calculate total sets for single exercise', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final totalSets = workout.totalSets;

        // Assert
        expect(totalSets, 3);
      });

      test('should calculate total sets for multiple exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2, exercise3],
        );

        // Act
        final totalSets = workout.totalSets;

        // Assert
        expect(totalSets, 10); // 3 + 4 + 3 = 10
      });

      test('should return zero for workout with no exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [],
        );

        // Act
        final totalSets = workout.totalSets;

        // Assert
        expect(totalSets, 0);
      });
    });

    group('exerciseCount', () {
      test('should return correct count for multiple exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2, exercise3],
        );

        // Act & Assert
        expect(workout.exerciseCount, 3);
      });

      test('should return zero for empty exercise list', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [],
        );

        // Act & Assert
        expect(workout.exerciseCount, 0);
      });
    });

    group('addExercise', () {
      test('should add exercise to empty workout', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [],
        );

        // Act
        final updated = workout.addExercise(exercise1);

        // Assert
        expect(updated.exercises.length, 1);
        expect(updated.exercises[0], exercise1);
        expect(workout.exercises.length, 0); // Original unchanged
      });

      test('should add exercise to workout with existing exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2],
        );

        // Act
        final updated = workout.addExercise(exercise3);

        // Assert
        expect(updated.exercises.length, 3);
        expect(updated.exercises[2], exercise3);
        expect(workout.exercises.length, 2); // Original unchanged
      });

      test('should preserve exercise order when adding', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final updated = workout.addExercise(exercise2).addExercise(exercise3);

        // Assert
        expect(updated.exercises[0], exercise1);
        expect(updated.exercises[1], exercise2);
        expect(updated.exercises[2], exercise3);
      });
    });

    group('removeExercise', () {
      test('should remove exercise by id', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2, exercise3],
        );

        // Act
        final updated = workout.removeExercise('2');

        // Assert
        expect(updated.exercises.length, 2);
        expect(updated.exercises.any((e) => e.id == '2'), false);
        expect(workout.exercises.length, 3); // Original unchanged
      });

      test('should handle removing non-existent exercise', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2],
        );

        // Act
        final updated = workout.removeExercise('999');

        // Assert
        expect(updated.exercises.length, 2);
        expect(updated.exercises, workout.exercises);
      });

      test('should handle removing from empty workout', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [],
        );

        // Act
        final updated = workout.removeExercise('1');

        // Assert
        expect(updated.exercises, isEmpty);
      });

      test('should preserve order of remaining exercises', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2, exercise3],
        );

        // Act
        final updated = workout.removeExercise('2');

        // Assert
        expect(updated.exercises[0], exercise1);
        expect(updated.exercises[1], exercise3);
      });
    });

    group('copyWith', () {
      test('should create copy with modified name', () {
        // Arrange
        final original = Workout(
          id: '1',
          name: 'Upper Body',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final copy = original.copyWith(name: 'Upper Body - Modified');

        // Assert
        expect(copy.name, 'Upper Body - Modified');
        expect(copy.id, original.id);
        expect(copy.date, original.date);
        expect(copy.exercises, original.exercises);
      });

      test('should create copy with modified date', () {
        // Arrange
        final original = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final copy = original.copyWith(date: DateTime(2024, 1, 20));

        // Assert
        expect(copy.date, DateTime(2024, 1, 20));
        expect(copy.id, original.id);
      });

      test('should create copy with modified exercises', () {
        // Arrange
        final original = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final copy = original.copyWith(
          exercises: const [exercise1, exercise2],
        );

        // Assert
        expect(copy.exercises.length, 2);
        expect(original.exercises.length, 1);
      });

      test('should create copy with modified duration', () {
        // Arrange
        final original = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
          duration: const Duration(minutes: 30),
        );

        // Act
        final copy = original.copyWith(duration: const Duration(minutes: 45));

        // Assert
        expect(copy.duration, const Duration(minutes: 45));
        expect(original.duration, const Duration(minutes: 30));
      });

      test('should create copy with modified notes', () {
        // Arrange
        final original = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final copy = original.copyWith(notes: 'New notes');

        // Assert
        expect(copy.notes, 'New notes');
        expect(original.notes, null);
      });

      test('should create copy with multiple modified fields', () {
        // Arrange
        final original = Workout(
          id: '1',
          name: 'Original',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final copy = original.copyWith(
          name: 'Modified',
          exercises: const [exercise1, exercise2],
          notes: 'Test notes',
        );

        // Assert
        expect(copy.name, 'Modified');
        expect(copy.exercises.length, 2);
        expect(copy.notes, 'Test notes');
      });
    });

    group('equality', () {
      test('should be equal when IDs match', () {
        // Arrange
        final workout1 = Workout(
          id: '1',
          name: 'Upper Body',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        final workout2 = Workout(
          id: '1',
          name: 'Different Name',
          date: DateTime(2024, 2, 20),
          exercises: const [exercise2],
        );

        // Act & Assert
        expect(workout1, equals(workout2));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final workout1 = Workout(
          id: '1',
          name: 'Upper Body',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        final workout2 = Workout(
          id: '2',
          name: 'Upper Body',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act & Assert
        expect(workout1, isNot(equals(workout2)));
      });

      test('should have same hashCode when IDs match', () {
        // Arrange
        final workout1 = Workout(
          id: '1',
          name: 'Upper Body',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        final workout2 = Workout(
          id: '1',
          name: 'Different Name',
          date: DateTime(2024, 2, 20),
          exercises: const [exercise2],
        );

        // Act & Assert
        expect(workout1.hashCode, equals(workout2.hashCode));
      });
    });

    group('toString', () {
      test('should include all fields in string representation', () {
        // Arrange
        final workout = Workout(
          id: '1',
          name: 'Upper Body Day',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1, exercise2],
          duration: const Duration(minutes: 45),
          notes: 'Great session',
        );

        // Act
        final string = workout.toString();

        // Assert
        expect(string, contains('1'));
        expect(string, contains('Upper Body Day'));
        expect(string, contains('2024-01-15'));
        expect(string, contains('2')); // exerciseCount
        expect(string, contains('4700.0')); // totalVolume
        expect(string, contains('7')); // totalSets
        expect(string, contains('0:45:00')); // duration
        expect(string, contains('Great session'));
      });

      test('should handle null optional fields in string representation', () {
        // Arrange
        final workout = Workout(
          id: '1',
          date: DateTime(2024, 1, 15),
          exercises: const [exercise1],
        );

        // Act
        final string = workout.toString();

        // Assert
        expect(string, contains('1'));
        expect(string, contains('null')); // name, duration, notes
      });
    });
  });
}
