import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/domain/entities/workout.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';
import 'package:fitness_tracker/presentation/screens/home_screen.dart';
import 'package:fitness_tracker/presentation/providers/workout_providers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    // Test fixtures
    final testDate = DateTime(2024, 1, 15);

    const exercise1 = Exercise(
      id: '1',
      name: 'Bench Press',
      sets: 3,
      reps: 10,
      weight: 50.0,
    );

    const exercise2 = Exercise(
      id: '2',
      name: 'Squat',
      sets: 4,
      reps: 8,
      weight: 100.0,
    );

    final testWorkout1 = Workout(
      id: '1',
      name: 'Upper Body Day',
      date: testDate,
      exercises: const [exercise1],
    );

    final testWorkout2 = Workout(
      id: '2',
      name: 'Leg Day',
      date: testDate.subtract(const Duration(days: 1)),
      exercises: const [exercise2],
    );

    // Helper function to create test widget with providers
    Widget createTestWidget({
      required AsyncValue<List<Workout>> workoutsState,
    }) {
      return ProviderScope(
        overrides: [
          workoutListProvider.overrideWith((ref) => workoutsState),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    group('loading state', () {
      testWidgets('should display loading indicator when loading', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.loading(),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should center loading indicator', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.loading(),
          ),
        );

        // Assert
        final center = find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Center),
        );
        expect(center, findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('should display error message when error occurs', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.error(
              Exception('Database error'),
              StackTrace.empty,
            ),
          ),
        );

        // Assert
        expect(find.text('Error loading workouts'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should display error details', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.error(
              Exception('Database connection failed'),
              StackTrace.empty,
            ),
          ),
        );

        // Assert
        expect(find.textContaining('Database connection failed'), findsOneWidget);
      });

      testWidgets('should display retry button on error', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.error(
              Exception('Test error'),
              StackTrace.empty,
            ),
          ),
        );

        // Assert
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should center error message', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.error(
              Exception('Test error'),
              StackTrace.empty,
            ),
          ),
        );

        // Assert
        final center = find.ancestor(
          of: find.text('Error loading workouts'),
          matching: find.byType(Center),
        );
        expect(center, findsOneWidget);
      });
    });

    group('empty state', () {
      testWidgets('should display empty state when no workouts', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.text('No workouts yet'), findsOneWidget);
        expect(find.text('Tap + to add your first workout'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('should center empty state message', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        final center = find.ancestor(
          of: find.text('No workouts yet'),
          matching: find.byType(Center),
        );
        expect(center, findsOneWidget);
      });
    });

    group('workouts list', () {
      testWidgets('should display workouts when data is available', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.text('Upper Body Day'), findsOneWidget);
        expect(find.text('Leg Day'), findsOneWidget);
      });

      testWidgets('should display workout count and volume', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );

        // Assert
        expect(find.text('1 exercises • 1500 kg total volume'), findsOneWidget);
      });

      testWidgets('should use ListView.builder for workouts', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should display cards for each workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.byType(Card), findsNWidgets(2));
      });

      testWidgets('should display fitness_center icon for each workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.fitness_center), findsNWidgets(2));
      });

      testWidgets('should display chevron_right icon for each workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
      });

      testWidgets('should display CircleAvatar for each workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1, testWorkout2]),
          ),
        );

        // Assert
        expect(find.byType(CircleAvatar), findsNWidgets(2));
      });

      testWidgets('should display default name for workout without name', (tester) async {
        // Arrange
        final workoutWithoutName = Workout(
          id: '3',
          date: testDate,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([workoutWithoutName]),
          ),
        );

        // Assert
        expect(find.text('Workout'), findsOneWidget);
      });

      testWidgets('should have RefreshIndicator for pull-to-refresh', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('should display formatted date for each workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );

        // Assert
        // Date should be formatted as "Monday, Jan 15, 2024" (format varies by locale)
        expect(find.textContaining('2024'), findsOneWidget);
      });
    });

    group('app bar', () {
      testWidgets('should display app bar with title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Workout Tracker'), findsOneWidget);
      });

      testWidgets('should center app bar title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.centerTitle, true);
      });
    });

    group('floating action button', () {
      testWidgets('should display floating action button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should display "Add Workout" label on FAB', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.text('Add Workout'), findsOneWidget);
      });

      testWidgets('should display add icon on FAB', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('FAB should be visible in all states', (tester) async {
        // Test loading state
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.loading(),
          ),
        );
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Test error state
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.error(Exception('Error'), StackTrace.empty),
          ),
        );
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Test empty state
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Test data state
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle single workout', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );

        // Assert
        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Upper Body Day'), findsOneWidget);
      });

      testWidgets('should handle many workouts', (tester) async {
        // Arrange
        final manyWorkouts = List.generate(
          20,
          (i) => Workout(
            id: '$i',
            name: 'Workout $i',
            date: testDate.subtract(Duration(days: i)),
            exercises: const [exercise1],
          ),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data(manyWorkouts),
          ),
        );

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        // Not all cards will be visible due to viewport, but list should be scrollable
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('should handle workout with zero volume', (tester) async {
        // Arrange
        const bodyweightExercise = Exercise(
          id: '10',
          name: 'Push-ups',
          sets: 3,
          reps: 20,
          weight: 0.0,
        );

        final bodyweightWorkout = Workout(
          id: '10',
          name: 'Bodyweight Workout',
          date: testDate,
          exercises: const [bodyweightExercise],
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([bodyweightWorkout]),
          ),
        );

        // Assert
        expect(find.text('1 exercises • 0 kg total volume'), findsOneWidget);
      });

      testWidgets('should handle workout with multiple exercises', (tester) async {
        // Arrange
        final multiExerciseWorkout = Workout(
          id: '11',
          name: 'Full Body',
          date: testDate,
          exercises: const [exercise1, exercise2],
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([multiExerciseWorkout]),
          ),
        );

        // Assert
        // exercise1: 3 * 10 * 50 = 1500
        // exercise2: 4 * 8 * 100 = 3200
        // Total: 4700
        expect(find.text('2 exercises • 4700 kg total volume'), findsOneWidget);
      });

      testWidgets('should handle very long workout name', (tester) async {
        // Arrange
        final longNameWorkout = Workout(
          id: '12',
          name: 'A' * 100,
          date: testDate,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([longNameWorkout]),
          ),
        );

        // Assert
        expect(find.text('A' * 100), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('should use Scaffold as root widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should have proper padding on ListView', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: AsyncValue.data([testWorkout1]),
          ),
        );

        // Assert
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.padding, const EdgeInsets.all(16));
      });

      testWidgets('should use extended FAB', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            workoutsState: const AsyncValue.data([]),
          ),
        );

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.isExtended, true);
      });
    });

    group('theme integration', () {
      testWidgets('should adapt to custom theme', (tester) async {
        // Arrange
        final customTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutListProvider.overrideWith((ref) => AsyncValue.data([testWorkout1])),
            ],
            child: MaterialApp(
              theme: customTheme,
              home: const HomeScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should work in dark mode', (tester) async {
        // Arrange
        final darkTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutListProvider.overrideWith((ref) => AsyncValue.data([testWorkout1])),
            ],
            child: MaterialApp(
              theme: darkTheme,
              home: const HomeScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
