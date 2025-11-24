import 'package:hive/hive.dart';
import '../../domain/entities/exercise.dart';

part 'exercise_model.g.dart';

/// Data Model: ExerciseModel
///
/// Hive-specific model for storing exercises in local database.
/// Separate from domain entity to maintain Clean Architecture separation.
/// Handles serialization and conversion to/from domain entities.
@HiveType(typeId: 0)
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

  /// Convert from domain entity to data model
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

  /// Convert from data model to domain entity
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

  /// Convert to JSON (for backup/export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
    };
  }

  /// Convert from JSON (for backup/import)
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}
