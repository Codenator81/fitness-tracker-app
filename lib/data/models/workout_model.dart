import 'package:hive/hive.dart';
import '../../domain/entities/workout.dart';
import 'exercise_model.dart';

part 'workout_model.g.dart';

/// Data Model: WorkoutModel
///
/// Hive-specific model for storing workouts in local database.
/// Separate from domain entity to maintain Clean Architecture separation.
/// Handles serialization, nested exercises, and conversion to/from domain entities.
@HiveType(typeId: 1)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<ExerciseModel> exercises;

  @HiveField(4)
  final int? durationInSeconds;

  WorkoutModel({
    required this.id,
    this.name,
    required this.date,
    required this.exercises,
    this.durationInSeconds,
  });

  /// Convert from domain entity to data model
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      name: workout.name,
      date: workout.date,
      exercises: workout.exercises
          .map((exercise) => ExerciseModel.fromEntity(exercise))
          .toList(),
      durationInSeconds: workout.duration?.inSeconds,
    );
  }

  /// Convert from data model to domain entity
  Workout toEntity() {
    return Workout(
      id: id,
      name: name,
      date: date,
      exercises: exercises.map((model) => model.toEntity()).toList(),
      duration: durationInSeconds != null
          ? Duration(seconds: durationInSeconds!)
          : null,
    );
  }

  /// Convert to JSON (for backup/export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'durationInSeconds': durationInSeconds,
    };
  }

  /// Convert from JSON (for backup/import)
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      date: DateTime.parse(json['date'] as String),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationInSeconds: json['durationInSeconds'] as int?,
    );
  }
}
