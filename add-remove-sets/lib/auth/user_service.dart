import 'dart:async';

import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_repository.dart';
import 'package:flutter/foundation.dart';

class UserService {
  UserService({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;
  final ValueNotifier<User?> userNotifier = ValueNotifier(null);

  StreamSubscription<User?>? userStreamSubscription;

  User? signIn(String name) {
    final user = _userRepository.getUser(name);
    if (user == null) {
      throw Exception('User not found');
    }
    _userRepository.createSession(user.name);
    userNotifier.value = user;
    final userStream = _userRepository.listenToUser(user);
    userStreamSubscription = userStream?.listen((user) {
      userNotifier.value = user;
    });
    return user;
  }

  void signOut() {
    userStreamSubscription?.cancel();
    _userRepository.deleteSession(userNotifier.value!);
    userNotifier.value = null;
  }

  User? signUp(User user) {
    final createdUser = _userRepository.createUser(user);
    userNotifier.value = createdUser;
    return createdUser;
  }

  User? sessionExists() {
    final user = _userRepository.sessionExists();
    if (user == null) {
      return null;
    }
    userNotifier.value = user;
    final userStream = _userRepository.listenToUser(user);
    userStreamSubscription = userStream?.listen((user) {
      userNotifier.value = user;
    });
    return user;
  }
}
