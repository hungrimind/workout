import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/workout/workout_repository.dart';
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

class MockWorkoutRepository implements WorkoutRepository {
  bool createWorkoutSessionCalled = false;
  List<Map<String, dynamic>> savedExerciseSets = [];

  @override
  Future<int?> createWorkoutSession(int userId, DateTime date) async {
    createWorkoutSessionCalled = true;
    return 456;
  }

  @override
  bool saveExerciseSet(
      int sessionId, String exerciseName, int reps, int setNumber) {
    savedExerciseSets.add({
      'sessionId': sessionId,
      'exerciseName': exerciseName,
      'reps': reps,
      'setNumber': setNumber,
    });
    return true;
  }
}

void main() {
  group('WorkoutViewModel', () {
    late MockUserService mockUserService;
    late WorkoutViewModel viewModel;
    late MockWorkoutRepository mockWorkoutRepository;
    setUp(() {
      mockUserService = MockUserService();
      mockWorkoutRepository = MockWorkoutRepository();
      viewModel = WorkoutViewModel(
        userService: mockUserService,
        workoutRepository: mockWorkoutRepository,
      );
    });

    test('Initial state should have empty sets', () {
      // Verify all exercises are initialized with empty sets
      for (var exercise in viewModel.exercises) {
        expect(viewModel.exerciseSets[exercise]!.value, isEmpty,
            reason: 'New workout should start with no previous exercise sets');
      }
    });

    test('addSet should add a set to the specified exercise', () {
      // Act
      viewModel.addSet('Push-ups', 10);

      // Assert
      expect(viewModel.exerciseSets['Push-ups']!.value, [10],
          reason:
              'User should see their first set appear in the workout tracker');

      // Act again
      viewModel.addSet('Push-ups', 12);

      // Assert
      expect(viewModel.exerciseSets['Push-ups']!.value, [10, 12],
          reason:
              'Workout history should maintain the sequence of completed sets');
    });

    test('removeSet should remove a set from the specified exercise', () {
      // Arrange
      viewModel.addSet('Pull-ups', 8);
      viewModel.addSet('Pull-ups', 9);
      viewModel.addSet('Pull-ups', 10);

      // Act
      viewModel.removeSet('Pull-ups', 1);

      // Assert
      expect(viewModel.exerciseSets['Pull-ups']!.value, [8, 10],
          reason:
              'User should be able to remove incorrect entries while preserving other workout data');
    });

    test('finishWorkout should save sets to the database', () async {
      // Arrange
      viewModel.addSet('Push-ups', 10);
      viewModel.addSet('Push-ups', 12);
      viewModel.addSet('Squats', 15);

      // Act
      await viewModel.finishWorkout();

      // Assert
      // Verify createWorkoutSession was called
      expect(mockWorkoutRepository.createWorkoutSessionCalled, isTrue,
          reason:
              'User\'s workout session should be recorded when they finish exercising');

      // Verify sets were saved
      expect(mockWorkoutRepository.savedExerciseSets.length, equals(3),
          reason:
              'All completed exercise sets should be saved for progress tracking');

      // Check specific exercise sets were saved
      expect(
          mockWorkoutRepository.savedExerciseSets
              .where((set) => set['exerciseName'] == 'Push-ups')
              .length,
          equals(2),
          reason:
              'Multiple sets of the same exercise should be preserved for accurate workout history');
      expect(
          mockWorkoutRepository.savedExerciseSets
              .where((set) => set['exerciseName'] == 'Squats')
              .length,
          equals(1),
          reason:
              'Different exercise types should be correctly categorized in workout history');
    });

    test('finishWorkout should not save to database if no sets exist',
        () async {
      // Act
      await viewModel.finishWorkout();

      // Assert - should still create a workout session even if no sets
      expect(mockWorkoutRepository.createWorkoutSessionCalled, isTrue,
          reason:
              'Even empty workouts should be tracked to maintain consistent user history');
      expect(mockWorkoutRepository.savedExerciseSets.length, equals(0),
          reason:
              'System should handle workouts where user opened app but didn\'t log any exercises');
    });

    test('logout should call signOut on UserService', () {
      // Act
      viewModel.logout();

      // Assert
      expect(mockUserService.signOutCalled, isTrue,
          reason:
              'User session should end completely when logout is requested');
    });
  });
}
