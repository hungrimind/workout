import 'dart:async';

import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_repository.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:flutter/foundation.dart';

class DataViewModel {
  DataViewModel({
    required DatabaseAbstraction databaseAbstraction,
    required UserRepository userRepository,
  })  : _databaseAbstraction = databaseAbstraction,
        _userRepository = userRepository;

  final DatabaseAbstraction _databaseAbstraction;
  final UserRepository _userRepository;
  final ValueNotifier<List<User>> users = ValueNotifier<List<User>>([]);
  final ValueNotifier<List<AuthSession>> authSessions =
      ValueNotifier<List<AuthSession>>([]);
  final ValueNotifier<List<WorkoutSession>> workoutSessions =
      ValueNotifier<List<WorkoutSession>>([]);
  final ValueNotifier<List<ExerciseSet>> exerciseSets =
      ValueNotifier<List<ExerciseSet>>([]);

  StreamSubscription<List<User>>? _usersSubscription;
  StreamSubscription<List<AuthSession>>? _authSessionsSubscription;
  StreamSubscription<List<WorkoutSession>>? _workoutSessionsSubscription;
  StreamSubscription<List<ExerciseSet>>? _exerciseSetsSubscription;

  void init() {
    users.value = getAllUsers();
    authSessions.value = getAllAuthSessions();
    workoutSessions.value = getAllWorkoutSessions();
    exerciseSets.value = getAllExerciseSets();

    _usersSubscription = listenToAllUsers().listen((users) {
      this.users.value = users;
    });
    _authSessionsSubscription = listenToAllAuthSessions().listen((sessions) {
      authSessions.value = sessions;
    });
    _workoutSessionsSubscription =
        listenToAllWorkoutSessions().listen((sessions) {
      workoutSessions.value = sessions;
    });
    _exerciseSetsSubscription = listenToAllExerciseSets().listen((sets) {
      exerciseSets.value = sets;
    });
  }

  void dispose() {
    users.dispose();
    authSessions.dispose();
    workoutSessions.dispose();
    exerciseSets.dispose();
    _usersSubscription?.cancel();
    _authSessionsSubscription?.cancel();
    _workoutSessionsSubscription?.cancel();
    _exerciseSetsSubscription?.cancel();
  }

  Stream<List<User>> listenToAllUsers() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'users')
        .map((_) => getAllUsers());
  }

  List<User> getAllUsers() {
    const query = 'SELECT * FROM users ORDER BY id DESC';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => User.fromJson(row)).toList();
  }

  Stream<List<AuthSession>> listenToAllAuthSessions() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'sessions')
        .map((_) => getAllAuthSessions());
  }

  List<AuthSession> getAllAuthSessions() {
    const query = '''
      SELECT s.*, u.name as user_name 
      FROM sessions s
      JOIN users u ON s.user_id = u.id
      ORDER BY s.id DESC
    ''';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => AuthSession.fromJson(row)).toList();
  }

  Stream<List<WorkoutSession>> listenToAllWorkoutSessions() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'workout_sessions')
        .map((_) => getAllWorkoutSessions());
  }

  List<WorkoutSession> getAllWorkoutSessions() {
    const query = '''
      SELECT ws.*, u.name as user_name 
      FROM workout_sessions ws
      JOIN users u ON ws.user_id = u.id
      ORDER BY ws.id DESC
    ''';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => WorkoutSession.fromJson(row)).toList();
  }

  Stream<List<ExerciseSet>> listenToAllExerciseSets() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'exercise_sets')
        .map((_) => getAllExerciseSets());
  }

  List<ExerciseSet> getAllExerciseSets() {
    const query = '''
      SELECT 
        es.*,
        ws.user_id,
        u.name as user_name
      FROM exercise_sets es
      JOIN workout_sessions ws ON es.session_id = ws.id
      JOIN users u ON ws.user_id = u.id
      ORDER BY es.id DESC
    ''';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => ExerciseSet.fromJson(row)).toList();
  }

  void deleteUser(User user) {
    _userRepository.deleteUser(user);
  }
}

class AuthSession {
  final int id;
  final int userId;
  final String userName;

  AuthSession({
    required this.id,
    required this.userId,
    required this.userName,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
    );
  }
}

class WorkoutSession {
  final int id;
  final int userId;
  final String userName;
  final DateTime date;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class ExerciseSet {
  final int id;
  final int sessionId;
  final int userId;
  final String userName;
  final String exerciseName;
  final int reps;
  final int setNumber;
  final DateTime date;

  ExerciseSet({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.exerciseName,
    required this.reps,
    required this.setNumber,
    required this.date,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      exerciseName: json['exercise_name'] as String,
      reps: json['reps'] as int,
      setNumber: json['set_number'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
