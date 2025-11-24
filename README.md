# Fitness Tracker App - Clean Architecture Guide

Complete guide to building a workout tracker using **Clean Architecture** (Domain-First), Claude Code VS Code extension, and Riverpod.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Understanding Clean Architecture](#understanding-clean-architecture)
- [Claude Code VS Code Setup](#claude-code-vs-code-setup)
- [Subagents Configuration](#subagents-configuration)
- [Development Workflow](#development-workflow)
- [Phase 1: Project Setup](#phase-1-project-setup)
- [Phase 2: Architecture Planning](#phase-2-architecture-planning)
- [Phase 3: Domain Layer (Start Here!)](#phase-3-domain-layer-start-here)
- [Phase 4: Data Layer](#phase-4-data-layer)
- [Phase 5: Presentation Layer](#phase-5-presentation-layer)
- [Phase 6: Main App](#phase-6-main-app)
- [Phase 7: Testing](#phase-7-testing)
- [Phase 8: Review & Deploy](#phase-8-review--deploy)
- [GitHub Setup](#github-setup)
- [Why Domain-First?](#why-domain-first)

---

## Overview

**Correct Clean Architecture Order:**
```
1. Domain Layer (Core) ← START HERE
2. Data Layer (Implementation)  
3. Presentation Layer (UI)
```

**Technologies:**
- Flutter + Dart
- Clean Architecture (Domain-First)
- Riverpod (State Management)
- Hive (Local Storage)
- Claude Code (VS Code Extension)

**App Features:**
- Track workouts with exercises, sets, reps, weight
- Local data persistence
- Workout history and progress
- Clean, intuitive UI

---

## Prerequisites

**Required:**
- Flutter SDK 3.0+
- VS Code
- Claude Code VS Code Extension
- GitHub CLI

**Knowledge:**
- Basic Flutter/Dart
- State management concepts
- Clean Architecture principles

---

## Understanding Clean Architecture

### The Three Layers

#### 1. Domain Layer (Core - Innermost) ⭐
**Pure business logic with ZERO external dependencies**

```
domain/
├── entities/       # Pure Dart classes (Exercise, Workout)
├── repositories/   # Abstract interfaces
└── usecases/      # Business operations
```

**Rules:**
- ✅ Pure Dart only (no Flutter, Hive, JSON)
- ✅ Immutable entities
- ✅ Business logic lives here
- ✅ Testable without anything else

#### 2. Data Layer (Implementation)
**Implements domain interfaces**

```
data/
├── models/         # Hive/JSON models
├── datasources/    # Database operations
└── repositories/   # Implements domain interfaces
```

**Rules:**
- ✅ Implements domain repository interfaces
- ✅ Converts models ↔ entities
- ✅ Handles serialization

#### 3. Presentation Layer (UI)
**User interface**

```
presentation/
├── providers/      # Riverpod state management
├── screens/       # Full pages
└── widgets/       # Reusable components
```

**Rules:**
- ✅ Uses domain entities (not models!)
- ✅ Calls use cases via providers
- ✅ Never imports from data layer

### Dependency Rule

```
Presentation ──uses──> Domain <──implements── Data
```

**Dependencies always point inward to domain.**

---

## Claude Code VS Code Setup

### Install Extension

1. Open VS Code Extensions (Ctrl+Shift+X)
2. Search "Claude Code"
3. Install official Anthropic extension
4. Reload VS Code

### Open Claude Code

**Method 1:** Click Claude Code icon in left sidebar  
**Method 2:** Command Palette (Ctrl+Shift+P) → "Claude Code: Open"

### Key Features

- Chat interface in sidebar
- @mention files
- Inline diffs
- Multiple parallel sessions
- Real-time code changes

---

## Subagents Configuration

Subagents are specialized AI assistants stored as Markdown files with YAML frontmatter.

### Directory Structure

```
project/
└── .claude/
    └── agents/
        ├── architect.md
        ├── implementer.md
        ├── debugger.md
        ├── tester.md
        └── reviewer.md
```

### Create Directory

```bash
mkdir -p .claude/agents
```

### File Format

Each `.md` file:

```markdown
---
name: agent-name
description: When to use this agent
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

System prompt and instructions here...
```

### Creating Subagents

**Method 1:** Use Claude Code's `/agents` command  
**Method 2:** Create `.md` files manually (see examples below)

---

## Development Workflow

### Agent Workflow Pattern

```
Architect → Implementer → Debugger → Tester → Reviewer
```

**Key Principles:**
1. **Architect first** - Always plan before coding
2. **One agent at a time** - Don't mix responsibilities  
3. **Domain-first** - Start with business logic
4. **Test early** - Test domain layer immediately
5. **Review last** - Comprehensive review before deploy

### How to Invoke Subagents

In Claude Code chat:
```
@architect Design a rest timer feature...

@implementer Create the Exercise entity based on the architect's plan...

@debugger Review the workout repository for null safety issues...
```

Claude Code automatically discovers agents from `.claude/agents/` directory.

---

## Phase 1: Project Setup

### Create Flutter Project

```bash
mkdir fitness_tracker
cd fitness_tracker
flutter create .
```

### Create Subagent Files

#### `.claude/agents/architect.md`

```markdown
---
name: architect
description: Software architect for Flutter apps. Use for designing app structure, planning architecture, choosing packages, and making design decisions.
tools: Read, Grep, Glob
model: sonnet
---

You are a senior Flutter architect specializing in Clean Architecture.

## Responsibilities
- Design app structure (Domain → Data → Presentation)
- Define entities, interfaces, use cases
- Plan repository patterns
- Design state management architecture
- Choose packages

## Principles
- Always start with Domain Layer
- Follow dependency rule (inward)
- Keep business logic in domain
- Ensure clear separation of concerns

## When Designing
1. Understand business requirements
2. Define domain entities first
3. Create repository interfaces
4. Design use cases
5. Plan data layer implementation
6. Design presentation layer last

Provide folder structure, data flow, and rationale.
```

#### `.claude/agents/implementer.md`

```markdown
---
name: implementer
description: Flutter developer for writing code. Use for implementing features, creating files, writing Dart code, and building UI.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

You are an expert Flutter developer.

## Responsibilities
- Implement features per architect's design
- Write clean, maintainable Dart code
- Create Flutter widgets and screens
- Integrate packages properly
- Follow null safety and best practices

## Guidelines
- Follow architect's plan exactly
- Start with domain layer for new features
- Keep code modular and reusable
- Add documentation comments
- Handle errors appropriately

## Code Quality
- Use const constructors
- Follow Effective Dart
- Keep functions small
- Use meaningful names
```

#### `.claude/agents/debugger.md`

```markdown
---
name: debugger
description: Debugging specialist. Use for finding bugs, analyzing errors, checking null safety, and testing edge cases.
tools: Read, Grep, Bash, Glob
model: sonnet
---

You are a debugging specialist for Flutter apps.

## Responsibilities
- Identify bugs and root causes
- Analyze error messages
- Check null safety compliance
- Test edge cases
- Verify state management

## Process
1. Read relevant files systematically
2. Identify root cause
3. Suggest comprehensive fix
4. Explain why it occurred
5. Provide prevention strategies

## Check For
- Unhandled nulls
- Missing await keywords
- State management issues
- Memory leaks
- Type mismatches between layers
```

#### `.claude/agents/tester.md`

```markdown
---
name: tester
description: QA engineer. Use for writing tests, creating test suites, ensuring coverage, and verifying functionality.
tools: Read, Write, Edit, Bash, Grep
model: sonnet
---

You are a QA engineer specializing in Flutter testing.

## Responsibilities
- Write unit tests for business logic
- Create widget tests for UI
- Ensure adequate coverage (70%+)
- Test edge cases and errors

## Guidelines
- Test domain logic thoroughly
- Test data layer conversions
- Widget tests for UI components
- Use mocks for dependencies
- Test success and failure cases

## Structure
- Use setUp() and tearDown()
- Create test fixtures
- Descriptive test names
- Keep tests independent
```

#### `.claude/agents/reviewer.md`

```markdown
---
name: reviewer
description: Code quality reviewer. Use for final review, checking best practices, and optimizing performance.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer.

## Responsibilities
- Review code quality and best practices
- Identify performance issues
- Check architecture compliance
- Verify security practices

## Review Checklist

**Architecture:**
- Clean Architecture principles followed?
- Dependency rule respected?

**Flutter:**
- Const constructors used?
- Efficient widget rebuilds?

**Performance:**
- No memory leaks?
- Optimized queries?

**Quality:**
- Clear naming?
- Proper documentation?
- Error handling?

Provide specific feedback with file locations, issues, and fixes.
```

---

## Phase 2: Architecture Planning

### Open Claude Code

1. Click Claude Code icon in VS Code sidebar
2. Start new conversation

### Design Architecture

```
@architect Design a workout tracker app using Clean Architecture (Domain-First) and Riverpod.

Requirements:
- Track workouts with multiple exercises
- Each exercise: name, sets, reps, weight, notes
- Save locally using Hive
- View workout history with dates
- Calculate total volume per workout

Provide:
1. Complete folder structure (Domain → Data → Presentation)
2. Domain entities (pure Dart)
3. Repository interfaces (abstract)
4. Use cases
5. Data models structure
6. Riverpod provider architecture
7. Screens needed

Important: Start with Domain Layer design.
```

### Save Architecture

```
Save the architecture plan to ARCHITECTURE.md
```

---

## Phase 3: Domain Layer (Start Here!)

**This is correct Clean Architecture - Domain First!**

### Step 1: Create Domain Entities

```
@implementer Create domain entities following the architect's plan:

1. lib/domain/entities/exercise.dart
- Pure Dart class (NO external dependencies)
- Properties: id, name, sets, reps, weight, notes
- All fields final
- copyWith(), equality operators
- calculateVolume() method
- toString()

2. lib/domain/entities/workout.dart
- Pure Dart class
- Properties: id, name, date, exercises (List<Exercise>), duration
- All fields final
- copyWith(), equality operators
- Getters: totalVolume, exerciseCount
- Methods: addExercise(), removeExercise()
- toString()

These must be pure business logic - no Flutter, Hive, or any packages!
```

### Step 2: Create Repository Interface

```
@implementer Create domain repository interface:

lib/domain/repositories/workout_repository.dart

Abstract class with methods:
- Future<void> saveWorkout(Workout workout)
- Future<Workout?> getWorkoutById(String id)
- Future<List<Workout>> getAllWorkouts()
- Future<void> deleteWorkout(String id)
- Future<void> updateWorkout(Workout workout)

Use domain entities, add documentation.
```

### Step 3: Create Use Cases

```
@implementer Create use cases in lib/domain/usecases/:

Each use case is a separate file:

1. save_workout.dart
2. get_all_workouts.dart (with sorting by date)
3. get_workout_by_id.dart
4. delete_workout.dart
5. update_workout.dart

Each has:
- Constructor taking WorkoutRepository
- call() method
- Business logic (like sorting)
```

### Test Domain Layer

```bash
flutter test test/domain/
```

**Domain should be fully testable without anything else!**

---

## Phase 4: Data Layer

### Step 1: Add Dependencies

```
@implementer Add to pubspec.yaml:

dependencies:
  flutter_riverpod: ^2.5.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  intl: ^0.19.0
  uuid: ^4.5.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
  mocktail: ^1.0.4
```

```bash
flutter pub get
```

### Step 2: Create Data Models

```
@implementer Create data models with Hive:

1. lib/data/models/exercise_model.dart
- @HiveType(typeId: 0)
- @HiveField annotations
- toJson(), fromJson()
- toEntity() → converts to Exercise entity
- fromEntity() ← converts from Exercise entity

2. lib/data/models/workout_model.dart
- @HiveType(typeId: 1)
- @HiveField annotations
- Handle nested exercises
- toJson(), fromJson()
- toEntity() → converts to Workout entity
- fromEntity() ← converts from Workout entity

Key: Include model ↔ entity conversion methods!
```

### Step 3: Generate Hive Adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Create Data Source

```
@implementer Create lib/data/datasources/workout_local_datasource.dart

Class handling all Hive operations:
- init() - Initialize Hive, register adapters
- saveWorkout(WorkoutModel)
- getWorkout(String id)
- getAllWorkouts()
- deleteWorkout(String id)
- updateWorkout(WorkoutModel)
- clearAll() for testing

Add error handling to all methods.
```

### Step 5: Create Repository Implementation

```
@implementer Create lib/data/repositories/workout_repository_impl.dart

Implements WorkoutRepository interface from domain.

For each method:
1. Convert domain entity to data model
2. Call datasource
3. Convert data model back to domain entity
4. Handle errors

This bridges domain and data layers!
```

---

## Phase 5: Presentation Layer

### Step 1: Create Providers

```
@implementer Create lib/presentation/providers/workout_providers.dart

Setup Riverpod providers:

1. Datasource provider
2. Repository provider (uses datasource)
3. Use case providers (use repository)
4. WorkoutListNotifier with StateNotifierProvider
5. workoutListProvider for state

WorkoutListNotifier manages:
- AsyncValue<List<Workout>> state
- loadWorkouts(), addWorkout(), deleteWorkout() methods
- Loading, error, success states
```

### Step 2: Create Screens

```
@implementer Create screens:

1. lib/presentation/screens/home_screen.dart
- ConsumerWidget
- Watch workoutListProvider
- Handle AsyncValue states (loading, error, data)
- Display workout list or empty state
- FloatingActionButton to add workout
- Material Design 3

2. lib/presentation/screens/add_workout_screen.dart
- ConsumerStatefulWidget
- Form with validation
- Dynamic exercise list (add/remove)
- Save using SaveWorkout use case
- Handle loading, navigate back on success

3. lib/presentation/screens/workout_detail_screen.dart
- Display workout details
- Edit and delete actions
- Use domain Workout entity
```

### Step 3: Create Widgets

```
@implementer Create widgets:

1. lib/presentation/widgets/workout_card.dart
- Takes Workout entity
- Shows summary
- onTap, onDelete callbacks

2. lib/presentation/widgets/exercise_input.dart
- Form fields for exercise
- Validation
- onChange callback

3. lib/presentation/widgets/custom_button.dart
- Reusable button with loading state
```

---

## Phase 6: Main App

```
@implementer Update lib/main.dart:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final datasource = WorkoutLocalDatasource();
  await datasource.init();
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  Widget build(context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: HomeScreen(),
    );
  }
}
```

---

## Phase 7: Testing

### Debug

```
@debugger Review entire codebase:

Check each layer:
- Domain: Pure Dart? No dependencies? Business logic correct?
- Data: Conversions correct? Null safety? Repository implements interface?
- Presentation: Uses entities? State management correct? Efficient rebuilds?

Common issues: Missing awaits, unhandled nulls, type mismatches, memory leaks.
```

### Fix Bugs

```
@implementer Fix issues identified by debugger.
```

### Write Tests

```
@tester Create test suite:

DOMAIN (Most Important):
- test/domain/entities/exercise_test.dart
- test/domain/entities/workout_test.dart
- test/domain/usecases/save_workout_test.dart

DATA:
- test/data/models/exercise_model_test.dart
- test/data/repositories/workout_repository_impl_test.dart

PRESENTATION:
- test/presentation/widgets/workout_card_test.dart
- test/presentation/screens/home_screen_test.dart

Use mocktail. Aim for 70%+ coverage.
```

```bash
flutter test
flutter test --coverage
```

---

## Phase 8: Review & Deploy

### Code Review

```
@reviewer Comprehensive review:

Check:
- Clean Architecture compliance
- Flutter best practices
- Riverpod efficiency
- Performance optimization
- Code quality

Provide prioritized improvements (must-fix, should-fix, nice-to-have).
```

### Apply Improvements

```
@implementer Apply must-fix and should-fix items.
```

### Test App

```bash
flutter run
```

**Test:**
- Create workouts
- View history
- Data persistence
- Edge cases

---

## GitHub Setup

### Create Repository

```bash
# Initialize
git init
git add .
git commit -m "Initial commit: Fitness tracker with Clean Architecture"

# Create and push
gh repo create fitness-tracker --public --source=. --push

# Or private
gh repo create fitness-tracker --private --source=. --push
```

### .gitignore

```
# Flutter
.dart_tool/
.packages
build/
.flutter-plugins

# Hive
*.hive
*.lock

# IDE
.idea/
.vscode/
*.iml
```

---

## Why Domain-First?

### Benefits

#### 1. True Independence

```dart
// ✅ Test domain without anything else
test('totalVolume calculates correctly', () {
  final workout = Workout(
    exercises: [Exercise(sets: 3, reps: 10, weight: 50)],
  );
  expect(workout.totalVolume, 1500);
});
```

#### 2. Easy to Swap Implementations

```dart
// Interface never changes
abstract class WorkoutRepository {
  Future<void> saveWorkout(Workout workout);
}

// Swap implementations freely
class HiveRepositoryImpl implements WorkoutRepository {}
class FirebaseRepositoryImpl implements WorkoutRepository {}
```

#### 3. Clear Dependencies

```
Presentation → Uses → Domain
                        ↑
                   Implements
                        ↓
                      Data
```

### Common Mistakes

❌ **Using data models in UI**
```dart
// Wrong
final List<WorkoutModel> workouts = ...; // Data model!
```

✅ **Using domain entities**
```dart
// Correct
final List<Workout> workouts = ...; // Domain entity!
```

❌ **Domain depending on data**
```dart
// Wrong - domain shouldn't know about Hive
import 'package:hive/hive.dart';
class Exercise {
  @HiveField(0)
  final String name;
}
```

✅ **Pure domain**
```dart
// Correct - pure Dart
class Exercise {
  final String name;
  double calculateVolume() => sets * reps * weight;
}
```

---

## Validation Checklist

### Domain Layer ✓
- [ ] No imports from data/presentation
- [ ] No Flutter packages
- [ ] Pure Dart only
- [ ] Can test in isolation
- [ ] Contains business logic

### Data Layer ✓
- [ ] Implements domain interfaces
- [ ] Has toEntity/fromEntity conversions
- [ ] Never exposes models to presentation
- [ ] Handles serialization

### Presentation Layer ✓
- [ ] Never imports from data
- [ ] Uses domain entities only
- [ ] Calls use cases via providers
- [ ] UI code only

### Dependency Rule ✓
```
Presentation → Domain? ✓ YES
Data → Domain? ✓ YES
Domain → Data? ✗ NO
Domain → Presentation? ✗ NO
Presentation → Data? ✗ NO
```

---

## Timeline

| Phase | Time | Description |
|-------|------|-------------|
| 1 | 15 min | Setup, subagents |
| 2 | 30 min | Architecture planning |
| 3 | 45 min | Domain layer |
| 4 | 60 min | Data layer |
| 5 | 75 min | Presentation layer |
| 6 | 15 min | Main app |
| 7 | 45 min | Testing |
| 8 | 30 min | Review |
| **Total** | **~5 hours** | Complete app |

---

## Key Principles

✅ **Domain First** - Core business logic  
✅ **VS Code Extension** - Not terminal  
✅ **Subagents in .claude/agents/** - Markdown files  
✅ **Dependencies inward** - Always toward domain  
✅ **Test domain thoroughly** - Easiest and most important  
✅ **Pure entities** - No external dependencies  
✅ **Repository bridges layers** - Converts models ↔ entities

---

## Resources

- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev)
- [Hive](https://docs.hivedb.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub CLI](https://cli.github.com)

---

**Remember: Domain → Data → Presentation. Always.** 🎯
