import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_providers.dart';

/// Workout Detail Screen
///
/// Displays full details of a single workout including all exercises.
/// Provides options to edit and delete the workout.
class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name ?? 'Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
            tooltip: 'Delete Workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(workout.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      label: 'Total Exercises',
                      value: '${workout.exerciseCount}',
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      label: 'Total Sets',
                      value: '${workout.totalSets}',
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      label: 'Total Volume',
                      value: '${workout.totalVolume.toStringAsFixed(1)} kg',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercises Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Exercise List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight} kg',
                      style: const TextStyle(fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Volume:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${exercise.volume.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Notes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.notes!,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final deleteUseCase = ref.read(deleteWorkoutUseCaseProvider);
        await deleteUseCase(workout.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete workout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Widget for displaying a statistic row
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 16,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
