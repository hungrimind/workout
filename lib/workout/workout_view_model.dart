import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/workout/exercise.dart';
import 'package:demo/core/database_abstraction.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({
    required UserService userService,
    required DatabaseAbstraction database,
  })  : _userService = userService,
        _database = database {
    _initExercises();
  }

  final UserService _userService;
  final DatabaseAbstraction _database;
  final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];

  // Map to store the current reps for each exercise
  final Map<String, ValueNotifier<int>> currentReps = {};

  // Map to store previous reps for each exercise
  final Map<String, ValueNotifier<int>> previousReps = {};

  ValueNotifier<User?> get userNotifier => _userService.userNotifier;

  void _initExercises() {
    for (var exercise in exercises) {
      currentReps[exercise] = ValueNotifier(0);
      previousReps[exercise] = ValueNotifier(0);
    }
    _loadPreviousExercises();
  }

  Future<void> _loadPreviousExercises() async {
    if (userNotifier.value == null) return;

    for (var exercise in exercises) {
      final results = _database.dbSelect(
        'SELECT * FROM exercises WHERE userId = ? AND name = ? ORDER BY date DESC LIMIT 1',
        [userNotifier.value!.id, exercise],
      );

      if (results.isNotEmpty) {
        final lastExercise = Exercise.fromMap(results.first);
        previousReps[exercise]!.value = lastExercise.reps;
      }
    }
  }

  Future<void> saveExercise(String name, int reps) async {
    if (userNotifier.value == null) return;

    final exercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      reps: reps,
      date: DateTime.now(),
      userId: userNotifier.value!.id!,
    );

    _database.dbExecute(
      'INSERT INTO exercises (id, name, reps, date, userId) VALUES (?, ?, ?, ?, ?)',
      [
        exercise.id,
        exercise.name,
        exercise.reps,
        exercise.date.toIso8601String(),
        exercise.userId,
      ],
    );

    previousReps[name]!.value = reps;
    currentReps[name]!.value = 0;
  }

  void updateReps(String exercise, int reps) {
    currentReps[exercise]!.value = reps;
  }

  void logout() {
    _userService.deleteSession(userNotifier.value!);
  }
}
