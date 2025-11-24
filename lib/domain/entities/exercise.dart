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
  /// Uses double multiplication to prevent integer overflow
  double get volume => sets.toDouble() * reps.toDouble() * weight;

  /// Create a copy of this exercise with modified fields
  ///
  /// To explicitly set notes to null, use clearNotes: true
  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    bool clearNotes = false,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: clearNotes ? null : (notes ?? this.notes),
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
