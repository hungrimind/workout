import 'dart:async';

import 'package:demo/auth/user.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';

class UserRepository {
  UserRepository({required DatabaseAbstraction databaseAbstraction})
      : _databaseAbstraction = databaseAbstraction;

  final DatabaseAbstraction _databaseAbstraction;

  /// Creates a user and returns the created user
  ///
  /// Throws: [Exception]
  ///
  /// * [Exception] - If the user is not found
  User createUser(User user) {
    final query = 'INSERT INTO users (name, uid) VALUES  (?, ?)';
    _databaseAbstraction.dbExecute(query, [user.name, user.uid]);
    final dbUser = getUser(user.name);
    if (dbUser == null) {
      throw Exception('User not found');
    }
    _createSession(dbUser);
    return dbUser;
  }

  /// Delete any session for this user as well
  void deleteUser(User user) {
    deleteSession(user);

    final deleteUserQuery = 'DELETE FROM users WHERE id = ?';
    _databaseAbstraction.dbExecute(deleteUserQuery, [user.id]);
  }

  /// Creates a session for a user and returns the user
  ///
  /// Throws: [Exception]
  ///
  /// * [Exception] - If the user is not found
  User? createSession(String name) {
    final user = getUser(name);
    if (user == null) {
      throw Exception('User not found');
    }

    _createSession(user);
    return user;
  }

  User? sessionExists() {
    final query = 'SELECT * FROM sessions';
    final result = _databaseAbstraction.dbSelect(query);
    if (result.isEmpty) {
      return null;
    }

    final sessionUserId = result[0]['user_id'] as int;
    final userQuery = 'SELECT * FROM users WHERE id = ?';
    final userResult =
        _databaseAbstraction.dbSelect(userQuery, [sessionUserId]);
    final user = User.fromJson(userResult[0]);
    return user;
  }

  void deleteSession(User user) {
    final query = 'DELETE FROM sessions WHERE user_id = ?';
    _databaseAbstraction.dbExecute(query, [user.id]);
  }

  User? getUser(String name) {
    final query = 'SELECT * FROM users WHERE name = ?';
    final result = _databaseAbstraction.dbSelect(query, [name]);
    return result.map((row) => User.fromJson(row)).firstOrNull;
  }

  Stream<User?>? listenToUser(User user) {
    return _databaseAbstraction.dbUpdates
        .where((update) => update.tableName == 'users')
        .map((_) {
      final query = 'SELECT * FROM users WHERE name = ?';
      final result = _databaseAbstraction.dbSelect(query, [user.name]);
      final userResult = result.map((row) => User.fromJson(row)).firstOrNull;
      return userResult;
    });
  }

  User? _createSession(User user) {
    deleteSession(user);
    final insertQuery = 'INSERT INTO sessions (user_id) VALUES (?)';
    _databaseAbstraction.dbExecute(insertQuery, [user.id]);
    return null;
  }
}
