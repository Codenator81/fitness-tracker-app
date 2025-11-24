import 'package:flutter/material.dart';
import '../../domain/entities/exercise.dart';

/// Exercise Input Widget
///
/// Reusable form component for inputting exercise data.
/// Provides validation and change callbacks.
class ExerciseInput extends StatefulWidget {
  final Exercise? initialExercise;
  final Function(ExerciseInputData) onChange;
  final bool enabled;

  const ExerciseInput({
    super.key,
    this.initialExercise,
    required this.onChange,
    this.enabled = true,
  });

  @override
  State<ExerciseInput> createState() => _ExerciseInputState();
}

class _ExerciseInputState extends State<ExerciseInput> {
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialExercise?.name,
    );
    _setsController = TextEditingController(
      text: widget.initialExercise?.sets.toString(),
    );
    _repsController = TextEditingController(
      text: widget.initialExercise?.reps.toString(),
    );
    _weightController = TextEditingController(
      text: widget.initialExercise?.weight.toString(),
    );
    _notesController = TextEditingController(
      text: widget.initialExercise?.notes,
    );

    // Add listeners to notify parent of changes
    _nameController.addListener(_notifyChange);
    _setsController.addListener(_notifyChange);
    _repsController.addListener(_notifyChange);
    _weightController.addListener(_notifyChange);
    _notesController.addListener(_notifyChange);
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers to prevent memory leaks
    _nameController.removeListener(_notifyChange);
    _setsController.removeListener(_notifyChange);
    _repsController.removeListener(_notifyChange);
    _weightController.removeListener(_notifyChange);
    _notesController.removeListener(_notifyChange);

    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChange(ExerciseInputData(
      name: _nameController.text,
      sets: int.tryParse(_setsController.text),
      reps: int.tryParse(_repsController.text),
      weight: double.tryParse(_weightController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Name
        TextFormField(
          controller: _nameController,
          enabled: widget.enabled,
          decoration: const InputDecoration(
            labelText: 'Exercise Name *',
            hintText: 'e.g., Bench Press',
            prefixIcon: Icon(Icons.fitness_center),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter exercise name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Sets, Reps, Weight Row
        Row(
          children: [
            // Sets
            Expanded(
              child: TextFormField(
                controller: _setsController,
                enabled: widget.enabled,
                decoration: const InputDecoration(
                  labelText: 'Sets *',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),

            // Reps
            Expanded(
              child: TextFormField(
                controller: _repsController,
                enabled: widget.enabled,
                decoration: const InputDecoration(
                  labelText: 'Reps *',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),

            // Weight
            Expanded(
              child: TextFormField(
                controller: _weightController,
                enabled: widget.enabled,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) *',
                  prefixIcon: Icon(Icons.line_weight),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final doubleValue = double.tryParse(value);
                  if (doubleValue == null || doubleValue < 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          enabled: widget.enabled,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Any additional notes...',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}

/// Data class for exercise input
class ExerciseInputData {
  final String name;
  final int? sets;
  final int? reps;
  final double? weight;
  final String? notes;

  ExerciseInputData({
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
  });

  bool get isValid {
    return name.isNotEmpty &&
        sets != null &&
        sets! > 0 &&
        reps != null &&
        reps! > 0 &&
        weight != null &&
        weight! >= 0;
  }

  Exercise toExercise(String id) {
    if (!isValid) {
      throw StateError('Cannot create exercise from invalid input data');
    }
    return Exercise(
      id: id,
      name: name,
      sets: sets!,
      reps: reps!,
      weight: weight!,
      notes: notes,
    );
  }
}
