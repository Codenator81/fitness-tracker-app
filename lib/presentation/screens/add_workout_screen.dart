import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_providers.dart';

/// Add Workout Screen
///
/// Allows users to create a new workout with multiple exercises.
/// Uses a form with validation and dynamic exercise list.
class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Exercise> _exercises = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        onSave: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _editExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        exercise: _exercises[index],
        onSave: (exercise) {
          setState(() {
            _exercises[index] = exercise;
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workout = Workout(
        id: const Uuid().v4(),
        name: _nameController.text.isEmpty ? null : _nameController.text,
        date: _selectedDate,
        exercises: _exercises,
      );

      final saveUseCase = ref.read(saveWorkoutUseCaseProvider);
      await saveUseCase(workout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _totalVolume {
    return _exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveWorkout,
              tooltip: 'Save Workout',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 16),

            // Workout Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name (Optional)',
                hintText: 'e.g., Upper Body Day',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Total Volume Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Volume',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_totalVolume.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercises Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FilledButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exercise List
            if (_exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No exercises added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight} kg\n'
                      'Volume: ${exercise.volume.toStringAsFixed(1)} kg',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editExercise(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeExercise(index),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding/editing an exercise
class _ExerciseDialog extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;

  const _ExerciseDialog({
    this.exercise,
    required this.onSave,
  });

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name);
    _setsController = TextEditingController(
      text: widget.exercise?.sets.toString(),
    );
    _repsController = TextEditingController(
      text: widget.exercise?.reps.toString(),
    );
    _weightController = TextEditingController(
      text: widget.exercise?.weight.toString(),
    );
    _notesController = TextEditingController(text: widget.exercise?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        id: widget.exercise?.id ?? const Uuid().v4(),
        name: _nameController.text,
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        weight: double.parse(_weightController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      widget.onSave(exercise);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Bench Press',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _setsController,
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sets';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reps';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
