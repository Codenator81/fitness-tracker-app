/// Domain Entity: Exercise
/// Pure Dart class with no external dependencies
/// Represents a single exercise in a workout
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

  /// Calculate volume for this exercise (sets × reps × weight)
  double get volume => sets * reps * weight;

  /// Create a copy of this exercise with modified fields
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

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, sets: $sets, reps: $reps, weight: $weight, notes: $notes, volume: ${volume.toStringAsFixed(1)})';
  }
}
