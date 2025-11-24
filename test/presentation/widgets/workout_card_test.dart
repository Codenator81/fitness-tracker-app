import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/domain/entities/workout.dart';
import 'package:fitness_tracker/domain/entities/exercise.dart';
import 'package:fitness_tracker/presentation/widgets/workout_card.dart';

void main() {
  group('WorkoutCard Widget Tests', () {
    // Test fixtures
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

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

    final testWorkout = Workout(
      id: '1',
      name: 'Upper Body Day',
      date: today,
      exercises: const [exercise1, exercise2],
      duration: const Duration(minutes: 45),
      notes: 'Great session',
    );

    // Helper function to wrap widget in MaterialApp for testing
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('rendering', () {
      testWidgets('should display workout name', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.text('Upper Body Day'), findsOneWidget);
      });

      testWidgets('should display default name when workout name is null', (tester) async {
        // Arrange
        final workoutWithoutName = Workout(
          id: '2',
          date: today,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: workoutWithoutName)));

        // Assert
        expect(find.text('Workout'), findsOneWidget);
      });

      testWidgets('should display exercise count', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.text('2 exercises'), findsOneWidget);
      });

      testWidgets('should display total volume in kg', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        // exercise1: 3 * 10 * 50 = 1500
        // exercise2: 4 * 8 * 100 = 3200
        // Total: 4700
        expect(find.text('4700 kg'), findsOneWidget);
      });

      testWidgets('should display fitness_center icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byIcon(Icons.fitness_center), findsWidgets);
      });

      testWidgets('should display timeline icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byIcon(Icons.timeline), findsOneWidget);
      });

      testWidgets('should display chevron_right icon when onTap is provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('should not display chevron_right icon when onTap is null', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byIcon(Icons.chevron_right), findsNothing);
      });

      testWidgets('should display delete button by default', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onDelete: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('should not display delete button when showDeleteButton is false', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onDelete: () {},
            showDeleteButton: false,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      });

      testWidgets('should not display delete button when onDelete is null', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      });
    });

    group('date formatting', () {
      testWidgets('should display "Today" for today\'s workout', (tester) async {
        // Arrange
        final todayWorkout = Workout(
          id: '1',
          date: today,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: todayWorkout)));

        // Assert
        expect(find.text('Today'), findsOneWidget);
      });

      testWidgets('should display "Yesterday" for yesterday\'s workout', (tester) async {
        // Arrange
        final yesterdayWorkout = Workout(
          id: '2',
          date: yesterday,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: yesterdayWorkout)));

        // Assert
        expect(find.text('Yesterday'), findsOneWidget);
      });

      testWidgets('should display formatted date for older workouts', (tester) async {
        // Arrange
        final oldWorkout = Workout(
          id: '3',
          date: weekAgo,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: oldWorkout)));

        // Assert
        // Should find a formatted date (e.g., "Jan 15, 2024")
        expect(find.textContaining(','), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('should call onTap when card is tapped', (tester) async {
        // Arrange
        bool wasTapped = false;
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onTap: () => wasTapped = true,
          ),
        ));

        // Act
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Assert
        expect(wasTapped, true);
      });

      testWidgets('should not crash when tapping without onTap callback', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Act & Assert
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        // No crash means success
      });

      testWidgets('should call onDelete when delete button is pressed', (tester) async {
        // Arrange
        bool wasDeleted = false;
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onDelete: () => wasDeleted = true,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Assert
        expect(wasDeleted, true);
      });

      testWidgets('should have tooltip on delete button', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(
          WorkoutCard(
            workout: testWorkout,
            onDelete: () {},
          ),
        ));

        // Act
        final deleteButton = find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(IconButton),
        );

        // Assert
        expect(deleteButton, findsOneWidget);
        final iconButton = tester.widget<IconButton>(deleteButton);
        expect(iconButton.tooltip, 'Delete workout');
      });
    });

    group('edge cases', () {
      testWidgets('should handle workout with zero exercises', (tester) async {
        // Arrange
        final emptyWorkout = Workout(
          id: '4',
          name: 'Empty Workout',
          date: today,
          exercises: const [],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: emptyWorkout)));

        // Assert
        expect(find.text('0 exercises'), findsOneWidget);
        expect(find.text('0 kg'), findsOneWidget);
      });

      testWidgets('should handle workout with very large volume', (tester) async {
        // Arrange
        const heavyExercise = Exercise(
          id: '10',
          name: 'Heavy Lift',
          sets: 100,
          reps: 100,
          weight: 100.0,
        );

        final heavyWorkout = Workout(
          id: '5',
          name: 'Heavy Day',
          date: today,
          exercises: const [heavyExercise],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: heavyWorkout)));

        // Assert
        expect(find.text('1000000 kg'), findsOneWidget);
      });

      testWidgets('should handle very long workout name with ellipsis', (tester) async {
        // Arrange
        final longNameWorkout = Workout(
          id: '6',
          name: 'A' * 100,
          date: today,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: longNameWorkout)));

        // Assert
        final textWidget = tester.widget<Text>(find.text('A' * 100));
        expect(textWidget.maxLines, 1);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('should handle single exercise workout', (tester) async {
        // Arrange
        final singleExerciseWorkout = Workout(
          id: '7',
          date: today,
          exercises: const [exercise1],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: singleExerciseWorkout)));

        // Assert
        expect(find.text('1 exercises'), findsOneWidget);
      });

      testWidgets('should display correct volume for decimal weights', (tester) async {
        // Arrange
        const decimalExercise = Exercise(
          id: '8',
          name: 'Light Exercise',
          sets: 3,
          reps: 10,
          weight: 12.5,
        );

        final decimalWorkout = Workout(
          id: '8',
          date: today,
          exercises: const [decimalExercise],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: decimalWorkout)));

        // Assert
        // 3 * 10 * 12.5 = 375
        expect(find.text('375 kg'), findsOneWidget);
      });

      testWidgets('should handle workout with bodyweight exercises (zero weight)', (tester) async {
        // Arrange
        const bodyweightExercise = Exercise(
          id: '9',
          name: 'Push-ups',
          sets: 3,
          reps: 20,
          weight: 0.0,
        );

        final bodyweightWorkout = Workout(
          id: '9',
          date: today,
          exercises: const [bodyweightExercise],
        );

        // Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: bodyweightWorkout)));

        // Assert
        expect(find.text('0 kg'), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('should use Card as root widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should have InkWell for tap feedback', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('should have CircleAvatar for icon background', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('should have proper padding', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        final padding = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        );
        expect(padding, findsWidgets);
      });

      testWidgets('should expand content area with Expanded widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(WorkoutCard(workout: testWorkout)));

        // Assert
        expect(find.byType(Expanded), findsOneWidget);
      });
    });

    group('theme integration', () {
      testWidgets('should adapt to theme colors', (tester) async {
        // Arrange
        final customTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: WorkoutCard(workout: testWorkout),
            ),
          ),
        );

        // Assert
        final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(circleAvatar.backgroundColor, isNotNull);
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
          MaterialApp(
            theme: darkTheme,
            home: Scaffold(
              body: WorkoutCard(workout: testWorkout),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WorkoutCard), findsOneWidget);
      });
    });

    group('multiple cards', () {
      testWidgets('should render multiple cards in a list', (tester) async {
        // Arrange
        final workouts = [
          testWorkout,
          Workout(
            id: '10',
            name: 'Leg Day',
            date: yesterday,
            exercises: const [exercise2],
          ),
          Workout(
            id: '11',
            name: 'Cardio',
            date: weekAgo,
            exercises: const [exercise1],
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  return WorkoutCard(workout: workouts[index]);
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(WorkoutCard), findsNWidgets(3));
      });

      testWidgets('should handle tap on specific card in list', (tester) async {
        // Arrange
        String? tappedId;
        final workouts = [
          testWorkout,
          Workout(
            id: '12',
            name: 'Leg Day',
            date: yesterday,
            exercises: const [exercise2],
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  return WorkoutCard(
                    workout: workouts[index],
                    onTap: () => tappedId = workouts[index].id,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Leg Day'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedId, '12');
      });
    });
  });
}
