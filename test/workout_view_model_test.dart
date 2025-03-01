import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/workout/workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUserService implements UserService {
  final _userNotifier = ValueNotifier<User?>(
    User(id: 1, name: 'Test User', uid: 'test-uid'),
  );
  bool signOutCalled = false;

  @override
  ValueNotifier<User?> get userNotifier => _userNotifier;

  @override
  void signOut() {
    signOutCalled = true;
    _userNotifier.value = null;
  }

  // Add stubs for other methods that might be called
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDatabaseAbstraction implements DatabaseAbstraction {
  final List<Map<String, Object?>> sessionResults = [];
  final List<Map<String, Object?>> lastInsertRowIdResults = [];
  final Map<String, List<Map<String, Object?>>> exerciseResults = {};

  final List<String> executedQueries = [];
  final List<List<Object?>> executedParameters = [];

  MockDatabaseAbstraction() {
    // Setup default empty results for exercises
    final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];
    for (var exercise in exercises) {
      exerciseResults[exercise] = [];
    }
  }

  void setupSessionResults(List<Map<String, Object?>> results) {
    sessionResults.clear();
    sessionResults.addAll(results);
  }

  void setupExerciseResults(
      String exercise, List<Map<String, Object?>> results) {
    exerciseResults[exercise] = results;
  }

  void setupLastInsertRowIdResults(int id) {
    lastInsertRowIdResults.clear();
    lastInsertRowIdResults.add({'id': id});
  }

  @override
  List<Map<String, Object?>> dbSelect(String query,
      [List<Object?> parameters = const []]) {
    executedQueries.add(query);
    executedParameters.add(parameters);

    if (query.contains('workout_sessions') &&
        query.contains('ORDER BY date DESC')) {
      return sessionResults;
    } else if (query.contains('last_insert_rowid()')) {
      return lastInsertRowIdResults;
    } else if (query.contains('exercise_sets')) {
      // Extract exercise name from parameters
      final exerciseName = parameters.length > 1 ? parameters[1] as String : '';
      return exerciseResults[exerciseName] ?? [];
    }

    return [];
  }

  @override
  void dbExecute(String query, [List<Object?> parameters = const []]) {
    executedQueries.add(query);
    executedParameters.add(parameters);
  }

  // Add stubs for other methods that might be called
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WorkoutViewModel', () {
    late MockUserService mockUserService;
    late MockDatabaseAbstraction mockDatabase;
    late WorkoutViewModel viewModel;

    setUp(() {
      mockUserService = MockUserService();
      mockDatabase = MockDatabaseAbstraction();
      viewModel = WorkoutViewModel(
        userService: mockUserService,
        database: mockDatabase,
      );
    });

    test('Initial state should have empty sets', () {
      // Verify all exercises are initialized with empty sets
      for (var exercise in viewModel.exercises) {
        expect(viewModel.exerciseSets[exercise]!.value, isEmpty);
        expect(viewModel.previousSessionSets[exercise]!.value, isEmpty);
      }
    });

    test('addSet should add a set to the specified exercise', () {
      // Act
      viewModel.addSet('Push-ups', 10);

      // Assert
      expect(viewModel.exerciseSets['Push-ups']!.value, [10]);

      // Act again
      viewModel.addSet('Push-ups', 12);

      // Assert
      expect(viewModel.exerciseSets['Push-ups']!.value, [10, 12]);
    });

    test('removeSet should remove a set from the specified exercise', () {
      // Arrange
      viewModel.addSet('Pull-ups', 8);
      viewModel.addSet('Pull-ups', 9);
      viewModel.addSet('Pull-ups', 10);

      // Act
      viewModel.removeSet('Pull-ups', 1);

      // Assert
      expect(viewModel.exerciseSets['Pull-ups']!.value, [8, 10]);
    });

    test('loadPreviousExercises should load sets from the database', () {
      // Arrange
      mockDatabase.setupSessionResults([
        {'id': 123}
      ]);
      mockDatabase.setupExerciseResults('Push-ups', [
        {'reps': 10, 'set_number': 1},
        {'reps': 12, 'set_number': 2},
      ]);
      mockDatabase.setupExerciseResults('Pull-ups', [
        {'reps': 5, 'set_number': 1},
        {'reps': 6, 'set_number': 2},
      ]);

      // Act
      viewModel = WorkoutViewModel(
        userService: mockUserService,
        database: mockDatabase,
      );

      // Assert
      expect(viewModel.previousSessionSets['Push-ups']!.value, [10, 12]);
      expect(viewModel.previousSessionSets['Pull-ups']!.value, [5, 6]);
    });

    test('finishWorkout should save sets to the database', () {
      // Arrange
      mockDatabase.setupLastInsertRowIdResults(456);
      viewModel.addSet('Push-ups', 10);
      viewModel.addSet('Push-ups', 12);
      viewModel.addSet('Squats', 15);

      // Act
      viewModel.finishWorkout();

      // Assert
      // Verify session was created
      expect(
          mockDatabase.executedQueries
              .any((q) => q.contains('INSERT INTO workout_sessions')),
          isTrue);

      // Verify sets were saved
      expect(
        mockDatabase.executedQueries
            .where((q) => q.contains('INSERT INTO exercise_sets'))
            .length,
        equals(3), // 2 for push-ups + 1 for squats
      );

      // Verify previousSessionSets were updated
      expect(viewModel.previousSessionSets['Push-ups']!.value, [10, 12]);
      expect(viewModel.previousSessionSets['Squats']!.value, [15]);

      // Verify current sets were cleared
      expect(viewModel.exerciseSets['Push-ups']!.value, isEmpty);
      expect(viewModel.exerciseSets['Squats']!.value, isEmpty);
    });

    test('finishWorkout should not save to database if no sets exist', () {
      // Act
      viewModel.finishWorkout();

      // Assert
      // Verify no inserts happened
      expect(
          mockDatabase.executedQueries
              .any((q) => q.contains('INSERT INTO workout_sessions')),
          isFalse);
    });

    test('logout should call signOut on UserService', () {
      // Act
      viewModel.logout();

      // Assert
      expect(mockUserService.signOutCalled, isTrue);
    });
  });
}
