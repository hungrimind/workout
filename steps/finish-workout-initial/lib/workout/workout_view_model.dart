import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({
    required UserService userService,
    required WorkoutRepository workoutRepository,
  })  : _userService = userService,
        _workoutRepository = workoutRepository {
    _initExercises();
  }

  final UserService _userService;
  final WorkoutRepository _workoutRepository;
  ValueNotifier<User?> get userNotifier => _userService.userNotifier;

  final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];
  final Map<String, ValueNotifier<List<int>>> exerciseSets = {};

  void _initExercises() {
    for (var exercise in exercises) {
      exerciseSets[exercise] = ValueNotifier([]);
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
    final user = userNotifier.value;
    if (user == null || user.id == null) return;

    final userId = user.id!;
    // TODO: Create a workout session in database
    final sessionId = null;

    if (sessionId == null) return;

    // Save all sets for this session
    for (var exercise in exercises) {
      final sets = exerciseSets[exercise]!.value;
      for (var i = 0; i < sets.length; i++) {
        // TODO: Save sets to the database
      }
    }
  }

  void logout() {
    _userService.signOut();
  }
}
