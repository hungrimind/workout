import 'dart:async';

import 'package:demo/auth/user.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';

class WorkoutRepository {
  WorkoutRepository({required DatabaseAbstraction databaseAbstraction})
      : _databaseAbstraction = databaseAbstraction;

  final DatabaseAbstraction _databaseAbstraction;

  /// Creates a new workout session and returns the session ID
  ///
  /// Returns null if the session could not be created
  Future<int?> createWorkoutSession(int userId, DateTime date) async {
    _databaseAbstraction.dbExecute(
      'INSERT INTO workout_sessions (user_id, date) VALUES (?, ?)',
      [userId, date.toIso8601String()],
    );

    final results = _databaseAbstraction.dbSelect(
      'SELECT last_insert_rowid() as id',
      [],
    );

    if (results.isEmpty) return null;
    return results.first['id'] as int;
  }

  /// Saves an exercise set to the database
  ///
  /// Returns true if the set was saved successfully
  bool saveExerciseSet(
      int sessionId, String exerciseName, int reps, int setNumber) {
    try {
      _databaseAbstraction.dbExecute(
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
          exerciseName,
          reps,
          setNumber,
        ],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPreviousWorkoutSessions(
      int userId) async {
    final results = _databaseAbstraction.dbSelect(
      'SELECT * FROM workout_sessions WHERE user_id = ? ORDER BY date DESC LIMIT 1',
      [userId],
    );
    return results;
  }

  Future<List<Map<String, dynamic>>> getExerciseSets(
      int workoutId, String exerciseName) async {
    final results = _databaseAbstraction.dbSelect(
      'SELECT * FROM exercise_sets WHERE session_id = ? AND exercise_name = ? ORDER BY set_number ASC',
      [workoutId, exerciseName],
    );
    return results;
  }
}
