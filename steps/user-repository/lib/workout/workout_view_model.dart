import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:flutter/material.dart';

class WorkoutViewModel {
  WorkoutViewModel({required UserService userService})
      : _userService = userService;

  final UserService _userService;

  ValueNotifier<User?> get userNotifier => _userService.userNotifier;

  void logout() {
    _userService.signOut();
  }
}
