import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/data/models/exercise_model.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';

void main() {
  group('ExerciseModel Tests', () {
    // Test fixtures
    const testExercise = Exercise(
      id: '1',
      name: 'Bench Press',
      sets: 3,
      reps: 10,
      weight: 50.0,
      notes: 'Good form',
    );

    final testExerciseModel = ExerciseModel(
      id: '1',
      name: 'Bench Press',
      sets: 3,
      reps: 10,
      weight: 50.0,
      notes: 'Good form',
    );

    final testJson = {
      'id': '1',
      'name': 'Bench Press',
      'sets': 3,
      'reps': 10,
      'weight': 50.0,
      'notes': 'Good form',
    };

    group('fromEntity', () {
      test('should convert domain entity to data model correctly', () {
        // Act
        final model = ExerciseModel.fromEntity(testExercise);

        // Assert
        expect(model.id, testExercise.id);
        expect(model.name, testExercise.name);
        expect(model.sets, testExercise.sets);
        expect(model.reps, testExercise.reps);
        expect(model.weight, testExercise.weight);
        expect(model.notes, testExercise.notes);
      });

      test('should handle entity without optional notes', () {
        // Arrange
        const exerciseWithoutNotes = Exercise(
          id: '2',
          name: 'Squat',
          sets: 5,
          reps: 5,
          weight: 100.0,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithoutNotes);

        // Assert
        expect(model.notes, null);
      });

      test('should handle zero weight', () {
        // Arrange
        const bodyweightExercise = Exercise(
          id: '3',
          name: 'Push-ups',
          sets: 3,
          reps: 20,
          weight: 0.0,
        );

        // Act
        final model = ExerciseModel.fromEntity(bodyweightExercise);

        // Assert
        expect(model.weight, 0.0);
      });

      test('should handle decimal weight values', () {
        // Arrange
        const exerciseWithDecimalWeight = Exercise(
          id: '4',
          name: 'Dumbbell Curl',
          sets: 3,
          reps: 12,
          weight: 12.5,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithDecimalWeight);

        // Assert
        expect(model.weight, 12.5);
      });

      test('should handle large values', () {
        // Arrange
        const exerciseWithLargeValues = Exercise(
          id: '5',
          name: 'Heavy Deadlift',
          sets: 999,
          reps: 999,
          weight: 999.9,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithLargeValues);

        // Assert
        expect(model.sets, 999);
        expect(model.reps, 999);
        expect(model.weight, 999.9);
      });
    });

    group('toEntity', () {
      test('should convert data model to domain entity correctly', () {
        // Act
        final entity = testExerciseModel.toEntity();

        // Assert
        expect(entity.id, testExerciseModel.id);
        expect(entity.name, testExerciseModel.name);
        expect(entity.sets, testExerciseModel.sets);
        expect(entity.reps, testExerciseModel.reps);
        expect(entity.weight, testExerciseModel.weight);
        expect(entity.notes, testExerciseModel.notes);
      });

      test('should handle model without optional notes', () {
        // Arrange
        final modelWithoutNotes = ExerciseModel(
          id: '2',
          name: 'Squat',
          sets: 5,
          reps: 5,
          weight: 100.0,
        );

        // Act
        final entity = modelWithoutNotes.toEntity();

        // Assert
        expect(entity.notes, null);
      });

      test('should preserve all data during conversion', () {
        // Arrange
        final modelWithAllFields = ExerciseModel(
          id: '6',
          name: 'Romanian Deadlift',
          sets: 4,
          reps: 8,
          weight: 80.0,
          notes: 'Focus on hamstrings',
        );

        // Act
        final entity = modelWithAllFields.toEntity();

        // Assert
        expect(entity.id, '6');
        expect(entity.name, 'Romanian Deadlift');
        expect(entity.sets, 4);
        expect(entity.reps, 8);
        expect(entity.weight, 80.0);
        expect(entity.notes, 'Focus on hamstrings');
      });
    });

    group('fromEntity and toEntity round-trip', () {
      test('should maintain data integrity during round-trip conversion', () {
        // Act
        final model = ExerciseModel.fromEntity(testExercise);
        final entity = model.toEntity();

        // Assert
        expect(entity.id, testExercise.id);
        expect(entity.name, testExercise.name);
        expect(entity.sets, testExercise.sets);
        expect(entity.reps, testExercise.reps);
        expect(entity.weight, testExercise.weight);
        expect(entity.notes, testExercise.notes);
      });

      test('should handle round-trip without notes', () {
        // Arrange
        const exerciseWithoutNotes = Exercise(
          id: '7',
          name: 'Leg Press',
          sets: 4,
          reps: 12,
          weight: 200.0,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithoutNotes);
        final entity = model.toEntity();

        // Assert
        expect(entity.notes, null);
        expect(entity.id, exerciseWithoutNotes.id);
        expect(entity.name, exerciseWithoutNotes.name);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        // Act
        final json = testExerciseModel.toJson();

        // Assert
        expect(json['id'], testExerciseModel.id);
        expect(json['name'], testExerciseModel.name);
        expect(json['sets'], testExerciseModel.sets);
        expect(json['reps'], testExerciseModel.reps);
        expect(json['weight'], testExerciseModel.weight);
        expect(json['notes'], testExerciseModel.notes);
      });

      test('should handle null notes in JSON', () {
        // Arrange
        final modelWithoutNotes = ExerciseModel(
          id: '8',
          name: 'Chin-ups',
          sets: 3,
          reps: 8,
          weight: 0.0,
        );

        // Act
        final json = modelWithoutNotes.toJson();

        // Assert
        expect(json['notes'], null);
      });

      test('should preserve numeric precision in JSON', () {
        // Arrange
        final modelWithDecimalWeight = ExerciseModel(
          id: '9',
          name: 'Tricep Extension',
          sets: 3,
          reps: 15,
          weight: 7.5,
        );

        // Act
        final json = modelWithDecimalWeight.toJson();

        // Assert
        expect(json['weight'], 7.5);
      });

      test('should create valid JSON map structure', () {
        // Act
        final json = testExerciseModel.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json.keys, containsAll(['id', 'name', 'sets', 'reps', 'weight', 'notes']));
      });
    });

    group('fromJson', () {
      test('should convert JSON to model correctly', () {
        // Act
        final model = ExerciseModel.fromJson(testJson);

        // Assert
        expect(model.id, testJson['id']);
        expect(model.name, testJson['name']);
        expect(model.sets, testJson['sets']);
        expect(model.reps, testJson['reps']);
        expect(model.weight, testJson['weight']);
        expect(model.notes, testJson['notes']);
      });

      test('should handle JSON without optional notes', () {
        // Arrange
        final jsonWithoutNotes = {
          'id': '10',
          'name': 'Pull-ups',
          'sets': 4,
          'reps': 6,
          'weight': 0.0,
          'notes': null,
        };

        // Act
        final model = ExerciseModel.fromJson(jsonWithoutNotes);

        // Assert
        expect(model.notes, null);
      });

      test('should handle JSON with integer weight', () {
        // Arrange
        final jsonWithIntWeight = {
          'id': '11',
          'name': 'Barbell Row',
          'sets': 3,
          'reps': 8,
          'weight': 60, // Integer instead of double
          'notes': null,
        };

        // Act
        final model = ExerciseModel.fromJson(jsonWithIntWeight);

        // Assert
        expect(model.weight, 60.0);
        expect(model.weight, isA<double>());
      });

      test('should handle JSON with decimal weight', () {
        // Arrange
        final jsonWithDecimalWeight = {
          'id': '12',
          'name': 'Lateral Raise',
          'sets': 3,
          'reps': 12,
          'weight': 15.5,
          'notes': null,
        };

        // Act
        final model = ExerciseModel.fromJson(jsonWithDecimalWeight);

        // Assert
        expect(model.weight, 15.5);
      });

      test('should throw when required fields are missing', () {
        // Arrange
        final invalidJson = {
          'id': '13',
          'name': 'Incomplete Exercise',
          // Missing sets, reps, weight
        };

        // Act & Assert
        expect(
          () => ExerciseModel.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw when field types are incorrect', () {
        // Arrange
        final invalidJson = {
          'id': '14',
          'name': 'Bad Exercise',
          'sets': 'three', // String instead of int
          'reps': 10,
          'weight': 50.0,
          'notes': null,
        };

        // Act & Assert
        expect(
          () => ExerciseModel.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity during JSON round-trip', () {
        // Act
        final json = testExerciseModel.toJson();
        final model = ExerciseModel.fromJson(json);

        // Assert
        expect(model.id, testExerciseModel.id);
        expect(model.name, testExerciseModel.name);
        expect(model.sets, testExerciseModel.sets);
        expect(model.reps, testExerciseModel.reps);
        expect(model.weight, testExerciseModel.weight);
        expect(model.notes, testExerciseModel.notes);
      });

      test('should handle JSON round-trip without notes', () {
        // Arrange
        final modelWithoutNotes = ExerciseModel(
          id: '15',
          name: 'Calf Raise',
          sets: 4,
          reps: 15,
          weight: 80.0,
        );

        // Act
        final json = modelWithoutNotes.toJson();
        final model = ExerciseModel.fromJson(json);

        // Assert
        expect(model.notes, null);
        expect(model.id, modelWithoutNotes.id);
        expect(model.name, modelWithoutNotes.name);
      });

      test('should preserve decimal precision during JSON round-trip', () {
        // Arrange
        final modelWithDecimals = ExerciseModel(
          id: '16',
          name: 'Hammer Curl',
          sets: 3,
          reps: 10,
          weight: 22.5,
        );

        // Act
        final json = modelWithDecimals.toJson();
        final model = ExerciseModel.fromJson(json);

        // Assert
        expect(model.weight, 22.5);
      });
    });

    group('full conversion chain', () {
      test('should maintain data integrity: Entity -> Model -> JSON -> Model -> Entity', () {
        // Act
        final model1 = ExerciseModel.fromEntity(testExercise);
        final json = model1.toJson();
        final model2 = ExerciseModel.fromJson(json);
        final entity = model2.toEntity();

        // Assert
        expect(entity.id, testExercise.id);
        expect(entity.name, testExercise.name);
        expect(entity.sets, testExercise.sets);
        expect(entity.reps, testExercise.reps);
        expect(entity.weight, testExercise.weight);
        expect(entity.notes, testExercise.notes);
      });

      test('should handle full conversion chain without notes', () {
        // Arrange
        const exerciseWithoutNotes = Exercise(
          id: '17',
          name: 'Plank',
          sets: 3,
          reps: 1,
          weight: 0.0,
        );

        // Act
        final model1 = ExerciseModel.fromEntity(exerciseWithoutNotes);
        final json = model1.toJson();
        final model2 = ExerciseModel.fromJson(json);
        final entity = model2.toEntity();

        // Assert
        expect(entity.notes, null);
        expect(entity.id, exerciseWithoutNotes.id);
        expect(entity.name, exerciseWithoutNotes.name);
        expect(entity.weight, exerciseWithoutNotes.weight);
      });
    });

    group('edge cases', () {
      test('should handle empty string notes', () {
        // Arrange
        const exerciseWithEmptyNotes = Exercise(
          id: '18',
          name: 'Test Exercise',
          sets: 3,
          reps: 10,
          weight: 50.0,
          notes: '',
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithEmptyNotes);
        final entity = model.toEntity();

        // Assert
        expect(entity.notes, '');
      });

      test('should handle very long exercise name', () {
        // Arrange
        final exerciseWithLongName = Exercise(
          id: '19',
          name: 'A' * 1000,
          sets: 3,
          reps: 10,
          weight: 50.0,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithLongName);
        final entity = model.toEntity();

        // Assert
        expect(entity.name.length, 1000);
      });

      test('should handle very long notes', () {
        // Arrange
        final exerciseWithLongNotes = Exercise(
          id: '20',
          name: 'Test Exercise',
          sets: 3,
          reps: 10,
          weight: 50.0,
          notes: 'N' * 5000,
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithLongNotes);
        final entity = model.toEntity();

        // Assert
        expect(entity.notes?.length, 5000);
      });

      test('should handle special characters in name and notes', () {
        // Arrange
        const exerciseWithSpecialChars = Exercise(
          id: '21',
          name: 'Test (Exercise) #1 @Home',
          sets: 3,
          reps: 10,
          weight: 50.0,
          notes: 'Notes with symbols: !@#\$%^&*()',
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithSpecialChars);
        final json = model.toJson();
        final model2 = ExerciseModel.fromJson(json);
        final entity = model2.toEntity();

        // Assert
        expect(entity.name, exerciseWithSpecialChars.name);
        expect(entity.notes, exerciseWithSpecialChars.notes);
      });

      test('should handle unicode characters', () {
        // Arrange
        const exerciseWithUnicode = Exercise(
          id: '22',
          name: 'Übung für Schultern 💪',
          sets: 3,
          reps: 10,
          weight: 50.0,
          notes: 'Notas en español: ñáéíóú',
        );

        // Act
        final model = ExerciseModel.fromEntity(exerciseWithUnicode);
        final json = model.toJson();
        final model2 = ExerciseModel.fromJson(json);
        final entity = model2.toEntity();

        // Assert
        expect(entity.name, exerciseWithUnicode.name);
        expect(entity.notes, exerciseWithUnicode.notes);
      });
    });
  });
}
