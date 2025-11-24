import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/workout_providers.dart';
import 'add_workout_screen.dart';
import 'workout_detail_screen.dart';

/// Home Screen
///
/// Displays a list of all workouts with Material Design 3.
/// Uses Riverpod to watch workout list state and handle loading/error/success states.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        centerTitle: true,
      ),
      body: workoutsAsync.when(
        // Loading state
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // Error state
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading workouts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(workoutListNotifierProvider.notifier).loadWorkouts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        // Success state with data
        data: (workouts) {
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first workout',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(workoutListNotifierProvider.notifier).loadWorkouts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      workout.name ?? 'Workout',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(workout.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${workout.exerciseCount} exercises • '
                          '${workout.totalVolume.toStringAsFixed(0)} kg total volume',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workout: workout),
                        ),
                      ).then((_) {
                        // Reload workouts when returning from detail screen
                        ref.read(workoutListNotifierProvider.notifier).loadWorkouts();
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddWorkoutScreen(),
            ),
          ).then((_) {
            // Reload workouts when returning from add screen
            ref.read(workoutListNotifierProvider.notifier).loadWorkouts();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }
}
