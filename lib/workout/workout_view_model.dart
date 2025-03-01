import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({
    required UserService userService,
    required DatabaseAbstraction database,
  })  : _userService = userService,
        _database = database {
    _initExercises();
    _loadPreviousExercises();
  }

  final UserService _userService;
  final DatabaseAbstraction _database;
  final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];

  // Map to store sets for each exercise
  final Map<String, ValueNotifier<List<int>>> exerciseSets = {};

  // Map to store previous session's sets for each exercise
  final Map<String, ValueNotifier<List<int>>> previousSessionSets = {};

  ValueNotifier<User?> get userNotifier => _userService.userNotifier;

  void _initExercises() {
    for (var exercise in exercises) {
      exerciseSets[exercise] = ValueNotifier([]);
      previousSessionSets[exercise] = ValueNotifier([]);
    }
  }

  Future<void> _loadPreviousExercises() async {
    if (userNotifier.value == null) return;

    // Get the last workout session for this user
    final sessionResults = _database.dbSelect(
      '''
      SELECT * FROM workout_sessions 
      WHERE user_id = ? 
      ORDER BY date DESC 
      LIMIT 1
      ''',
      [userNotifier.value!.id],
    );

    if (sessionResults.isEmpty) return;

    final lastSessionId = sessionResults.first['id'] as int;

    // Load all exercises from that session
    for (var exercise in exercises) {
      final results = _database.dbSelect(
        '''
        SELECT * FROM exercise_sets 
        WHERE session_id = ? 
        AND exercise_name = ?
        ORDER BY set_number ASC
        ''',
        [lastSessionId, exercise],
      );

      if (results.isNotEmpty) {
        // Store all sets from the previous session
        final previousSets = results.map((row) => row['reps'] as int).toList();
        previousSessionSets[exercise]!.value = previousSets;
      }
    }
  }

  void addSet(String exerciseName, int reps) {
    final currentSets = List<int>.from(exerciseSets[exerciseName]!.value);
    currentSets.add(reps);
    exerciseSets[exerciseName]!.value = currentSets;
  }

  void removeSet(String exercise, int index) {
    final currentSets = List<int>.from(exerciseSets[exercise]!.value);
    currentSets.removeAt(index);
    exerciseSets[exercise]!.value = currentSets;
  }

  Future<void> finishWorkout() async {
    if (userNotifier.value == null) return;

    // Only save to database if there are any sets
    bool hasAnySets = false;
    for (var exercise in exercises) {
      if (exerciseSets[exercise]!.value.isNotEmpty) {
        hasAnySets = true;
        break;
      }
    }

    if (!hasAnySets) return;

    // Create workout session
    _database.dbExecute(
      'INSERT INTO workout_sessions (user_id, date) VALUES (?, ?)',
      [userNotifier.value!.id, DateTime.now().toIso8601String()],
    );

    final results = _database.dbSelect(
      'SELECT last_insert_rowid() as id',
      [],
    );

    if (results.isEmpty) return;

    final sessionId = results.first['id'] as int;

    // Save all sets for this session
    for (var exercise in exercises) {
      final sets = exerciseSets[exercise]!.value;
      for (var i = 0; i < sets.length; i++) {
        _database.dbExecute(
          '''
          INSERT INTO exercise_sets (
            session_id, 
            exercise_name, 
            reps, 
            set_number
          ) 
          VALUES (?, ?, ?, ?)
          ''',
          [
            sessionId,
            exercise,
            sets[i],
            i + 1,
          ],
        );
      }
    }

    // Update previous sets and clear current sets
    for (var exercise in exercises) {
      previousSessionSets[exercise]!.value =
          List.from(exerciseSets[exercise]!.value);
      exerciseSets[exercise]!.value = [];
    }
  }

  void logout() {
    _userService.signOut();
  }
}
