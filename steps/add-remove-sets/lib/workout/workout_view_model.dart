import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({required UserService userService})
      : _userService = userService {
    _initExercises();
  }

  final UserService _userService;
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

  void logout() {
    _userService.signOut();
  }
}
