import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({
    required UserService userService,
    required WorkoutRepository workoutRepository,
  })  : _userService = userService,
        _workoutRepository = workoutRepository {
    _initExercises();
    _loadPreviousExercises();
  }

  final UserService _userService;
  final WorkoutRepository _workoutRepository;
  ValueNotifier<User?> get userNotifier => _userService.userNotifier;

  final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];
  final Map<String, ValueNotifier<List<int>>> exerciseSets = {};
  final Map<String, ValueNotifier<List<int>>> previousSessionSets = {};

  void _initExercises() {
    for (var exercise in exercises) {
      exerciseSets[exercise] = ValueNotifier([]);
      previousSessionSets[exercise] = ValueNotifier([]);
    }
  }

  Future<void> _loadPreviousExercises() async {
    // Skip loading previous exercises if user is not logged in
    if (userNotifier.value == null || userNotifier.value!.id == null) return;

    final previousWorkouts =
        await _workoutRepository.getPreviousWorkoutSessions(
      userNotifier.value!.id!,
    );

    if (previousWorkouts.isEmpty) return;

    final previousWorkoutId = previousWorkouts.first['id'] as int;

    // Load all exercises from that session
    for (var exercise in exercises) {
      final results = await _workoutRepository.getExerciseSets(
        previousWorkoutId,
        exercise,
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
    final user = userNotifier.value;
    if (user == null || user.id == null) return;

    final userId = user.id!;
    final sessionId = await _workoutRepository.createWorkoutSession(
      userId,
      DateTime.now(),
    );

    if (sessionId == null) return;

    // Save all sets for this session
    for (var exercise in exercises) {
      final sets = exerciseSets[exercise]!.value;
      for (var i = 0; i < sets.length; i++) {
        _workoutRepository.saveExerciseSet(
          sessionId,
          exercise,
          sets[i],
          i + 1,
        );
      }
    }

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
