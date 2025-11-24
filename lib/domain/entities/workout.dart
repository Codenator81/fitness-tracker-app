import 'exercise.dart';

/// Domain Entity: Workout
/// Pure Dart class with no external dependencies
/// Represents a complete workout session with multiple exercises
class Workout {
  final String id;
  final String? name;
  final DateTime date;
  final List<Exercise> exercises;
  final Duration? duration;
  final String? notes;

  const Workout({
    required this.id,
    this.name,
    required this.date,
    required this.exercises,
    this.duration,
    this.notes,
  });

  /// Calculate total volume for entire workout (sum of all exercise volumes)
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
  }

  /// Get total number of sets across all exercises
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  /// Get total number of exercises in this workout
  int get exerciseCount => exercises.length;

  /// Add an exercise to this workout (returns new Workout instance)
  Workout addExercise(Exercise exercise) {
    return copyWith(
      exercises: [...exercises, exercise],
    );
  }

  /// Remove an exercise from this workout (returns new Workout instance)
  Workout removeExercise(String exerciseId) {
    return copyWith(
      exercises: exercises.where((e) => e.id != exerciseId).toList(),
    );
  }

  /// Create a copy of this workout with modified fields
  ///
  /// To explicitly set nullable fields to null, use the clear* parameters:
  /// - clearName: true to set name to null
  /// - clearDuration: true to set duration to null
  /// - clearNotes: true to set notes to null
  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<Exercise>? exercises,
    Duration? duration,
    String? notes,
    bool clearName = false,
    bool clearDuration = false,
    bool clearNotes = false,
  }) {
    return Workout(
      id: id ?? this.id,
      name: clearName ? null : (name ?? this.name),
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      duration: clearDuration ? null : (duration ?? this.duration),
      notes: clearNotes ? null : (notes ?? this.notes),
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

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, date: $date, exerciseCount: $exerciseCount, totalVolume: ${totalVolume.toStringAsFixed(1)}, totalSets: $totalSets, duration: $duration, notes: $notes)';
  }
}
