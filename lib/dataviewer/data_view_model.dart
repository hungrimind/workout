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
  final ValueNotifier<List<int>> sessions = ValueNotifier<List<int>>([]);
  final ValueNotifier<List<ExerciseRecord>> exercises =
      ValueNotifier<List<ExerciseRecord>>([]);

  StreamSubscription<List<User>>? _usersSubscription;
  StreamSubscription<List<int>>? _sessionsSubscription;
  StreamSubscription<List<ExerciseRecord>>? _exercisesSubscription;

  void init() {
    users.value = getAllUsers();
    sessions.value = getAllSessions();
    exercises.value = getAllExercises();

    _usersSubscription = listenToAllUsers().listen((users) {
      this.users.value = users;
    });
    _sessionsSubscription = listenToAllSessions().listen((sessions) {
      this.sessions.value = sessions;
    });
    _exercisesSubscription = listenToAllExercises().listen((exercises) {
      this.exercises.value = exercises;
    });
  }

  void dispose() {
    users.dispose();
    sessions.dispose();
    exercises.dispose();
    _usersSubscription?.cancel();
    _sessionsSubscription?.cancel();
    _exercisesSubscription?.cancel();
  }

  Stream<List<User>> listenToAllUsers() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'users')
        .map((_) {
      return getAllUsers();
    });
  }

  List<User> getAllUsers() {
    const query = 'SELECT * FROM users';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => User.fromJson(row)).toList();
  }

  void deleteUser(User user) {
    _userRepository.deleteUser(user);
  }

  Stream<List<int>> listenToAllSessions() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'sessions')
        .map((_) {
      return getAllSessions();
    });
  }

  List<int> getAllSessions() {
    const query = 'SELECT * FROM sessions';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => row['user_id'] as int).toList();
  }

  Stream<List<ExerciseRecord>> listenToAllExercises() {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'exercises')
        .map((_) {
      return getAllExercises();
    });
  }

  List<ExerciseRecord> getAllExercises() {
    const query = '''
      SELECT e.*, u.name as user_name 
      FROM exercises e 
      LEFT JOIN users u ON e.userId = u.id 
      ORDER BY e.date DESC
    ''';
    final result = _databaseAbstraction.dbSelect(query);
    return result.map((row) => ExerciseRecord.fromJson(row)).toList();
  }
}

class ExerciseRecord {
  final int id;
  final int userId;
  final String userName;
  final String exercise;
  final int reps;
  final DateTime timestamp;

  ExerciseRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.exercise,
    required this.reps,
    required this.timestamp,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['user_name'] as String,
      exercise: json['name'] as String,
      reps: json['reps'] as int,
      timestamp: DateTime.parse(json['date'] as String),
    );
  }
}
