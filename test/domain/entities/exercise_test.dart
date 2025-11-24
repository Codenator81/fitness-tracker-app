import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';

void main() {
  group('Exercise Entity Tests', () {
    test('should create exercise with all fields', () {
      // Arrange & Act
      const exercise = Exercise(
        id: '1',
        name: 'Bench Press',
        sets: 3,
        reps: 10,
        weight: 50.0,
        notes: 'Good form',
      );

      // Assert
      expect(exercise.id, '1');
      expect(exercise.name, 'Bench Press');
      expect(exercise.sets, 3);
      expect(exercise.reps, 10);
      expect(exercise.weight, 50.0);
      expect(exercise.notes, 'Good form');
    });

    test('should create exercise without optional notes', () {
      // Arrange & Act
      const exercise = Exercise(
        id: '1',
        name: 'Squat',
        sets: 5,
        reps: 5,
        weight: 100.0,
      );

      // Assert
      expect(exercise.notes, null);
    });

    group('volume calculation', () {
      test('should calculate volume correctly', () {
        // Arrange
        const exercise = Exercise(
          id: '1',
          name: 'Deadlift',
          sets: 3,
          reps: 8,
          weight: 80.0,
        );

        // Act
        final volume = exercise.volume;

        // Assert
        expect(volume, 1920.0); // 3 * 8 * 80 = 1920
      });

      test('should handle zero weight', () {
        // Arrange
        const exercise = Exercise(
          id: '1',
          name: 'Bodyweight Pushups',
          sets: 3,
          reps: 20,
          weight: 0.0,
        );

        // Act
        final volume = exercise.volume;

        // Assert
        expect(volume, 0.0);
      });

      test('should handle decimal weights', () {
        // Arrange
        const exercise = Exercise(
          id: '1',
          name: 'Dumbbell Curl',
          sets: 3,
          reps: 12,
          weight: 12.5,
        );

        // Act
        final volume = exercise.volume;

        // Assert
        expect(volume, 450.0); // 3 * 12 * 12.5 = 450
      });

      test('should prevent overflow with large values', () {
        // Arrange
        const exercise = Exercise(
          id: '1',
          name: 'Heavy Lift',
          sets: 999,
          reps: 999,
          weight: 999.9,
        );

        // Act
        final volume = exercise.volume;

        // Assert
        // 999 * 999 * 999.9 = 997,901,199.9 (using double multiplication to prevent overflow)
        expect(volume, closeTo(997901199.9, 0.1)); // Should not overflow
        expect(volume, isPositive);
      });
    });

    group('copyWith', () {
      test('should create copy with modified name', () {
        // Arrange
        const original = Exercise(
          id: '1',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        // Act
        final copy = original.copyWith(name: 'Incline Bench Press');

        // Assert
        expect(copy.name, 'Incline Bench Press');
        expect(copy.id, original.id);
        expect(copy.sets, original.sets);
        expect(copy.reps, original.reps);
        expect(copy.weight, original.weight);
      });

      test('should create copy with modified sets, reps, and weight', () {
        // Arrange
        const original = Exercise(
          id: '1',
          name: 'Squat',
          sets: 3,
          reps: 10,
          weight: 100.0,
        );

        // Act
        final copy = original.copyWith(
          sets: 5,
          reps: 5,
          weight: 120.0,
        );

        // Assert
        expect(copy.sets, 5);
        expect(copy.reps, 5);
        expect(copy.weight, 120.0);
        expect(copy.name, original.name);
      });

      test('should create copy with notes', () {
        // Arrange
        const original = Exercise(
          id: '1',
          name: 'Deadlift',
          sets: 3,
          reps: 5,
          weight: 140.0,
        );

        // Act
        final copy = original.copyWith(notes: 'Focus on form');

        // Assert
        expect(copy.notes, 'Focus on form');
      });
    });

    group('equality', () {
      test('should be equal when IDs match', () {
        // Arrange
        const exercise1 = Exercise(
          id: '1',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        const exercise2 = Exercise(
          id: '1',
          name: 'Different Name',
          sets: 5,
          reps: 5,
          weight: 100.0,
        );

        // Act & Assert
        expect(exercise1, equals(exercise2));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        const exercise1 = Exercise(
          id: '1',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        const exercise2 = Exercise(
          id: '2',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        // Act & Assert
        expect(exercise1, isNot(equals(exercise2)));
      });

      test('should have same hashCode when IDs match', () {
        // Arrange
        const exercise1 = Exercise(
          id: '1',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        const exercise2 = Exercise(
          id: '1',
          name: 'Different Name',
          sets: 5,
          reps: 5,
          weight: 100.0,
        );

        // Act & Assert
        expect(exercise1.hashCode, equals(exercise2.hashCode));
      });
    });

    group('toString', () {
      test('should include all fields in string representation', () {
        // Arrange
        const exercise = Exercise(
          id: '1',
          name: 'Bench Press',
          sets: 3,
          reps: 10,
          weight: 50.0,
          notes: 'Good form',
        );

        // Act
        final string = exercise.toString();

        // Assert
        expect(string, contains('1'));
        expect(string, contains('Bench Press'));
        expect(string, contains('3'));
        expect(string, contains('10'));
        expect(string, contains('50.0'));
        expect(string, contains('Good form'));
        expect(string, contains('1500.0')); // volume
      });
    });
  });
}
