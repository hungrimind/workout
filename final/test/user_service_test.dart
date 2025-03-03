import 'dart:async';

import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_repository.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUserRepository extends UserRepository {
  MockUserRepository() : super(databaseAbstraction: DatabaseAbstraction());

  User? userToReturn;
  User? sessionUser;
  User? createdUser;
  Stream<User?>? userStream;

  final calls = <String, List<dynamic>>{
    'getUser': [],
    'createSession': [],
    'deleteSession': [],
    'createUser': [],
    'sessionExists': [],
    'listenToUser': [],
  };

  @override
  User? getUser(String name) {
    calls['getUser']!.add(name);
    return userToReturn;
  }

  @override
  User? createSession(String name) {
    calls['createSession']!.add(name);
    return userToReturn;
  }

  @override
  void deleteSession(User user) {
    calls['deleteSession']!.add(user);
  }

  @override
  User createUser(User user) {
    calls['createUser']!.add(user);
    return createdUser ?? user;
  }

  @override
  User? sessionExists() {
    calls['sessionExists']!.add(null);
    return sessionUser;
  }

  @override
  Stream<User?>? listenToUser(User user) {
    calls['listenToUser']!.add(user);
    return userStream;
  }
}

void main() {
  late UserService userService;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    userService = UserService(userRepository: mockUserRepository);
  });

  group('UserService', () {
    final testUser = User(id: 1, name: 'TestUser', uid: 'test-uid-123');
    final updatedUser = User(id: 1, name: 'TestUser', uid: 'updated-uid-456');

    test('signIn should set user and listen to updates', () {
      // Arrange
      final userStreamController = StreamController<User?>();
      mockUserRepository.userToReturn = testUser;
      mockUserRepository.userStream = userStreamController.stream;

      // Act
      final result = userService.signIn('TestUser');

      // Assert
      expect(result?.uid, equals(testUser.uid));
      expect(userService.userNotifier.value?.uid, equals(testUser.uid));
      expect(mockUserRepository.calls['getUser'], contains('TestUser'));
      expect(mockUserRepository.calls['createSession'], contains('TestUser'));
      expect(mockUserRepository.calls['listenToUser'], contains(testUser));

      // Test stream updates
      userStreamController.add(updatedUser);
      // Wait for the event to be processed
      addTearDown(() async {
        await userStreamController.close();
      });

      // Use microtask to let the stream event be processed
      return Future.microtask(() {
        expect(userService.userNotifier.value?.uid, equals(updatedUser.uid));
      });
    });

    test('signIn should throw exception when user not found', () {
      // Arrange
      mockUserRepository.userToReturn = null;

      // Act & Assert
      expect(() => userService.signIn('NonExistentUser'), throwsException);
      expect(mockUserRepository.calls['getUser'], contains('NonExistentUser'));
      expect(mockUserRepository.calls['createSession'], isEmpty);
    });

    test('signOut should cancel subscription and clear user', () {
      // Arrange - sign in first
      final userStreamController = StreamController<User?>();
      mockUserRepository.userToReturn = testUser;
      mockUserRepository.userStream = userStreamController.stream;
      userService.signIn('TestUser');

      mockUserRepository.calls['deleteSession']!
          .clear(); // Clear previous calls

      // Act
      userService.signOut();

      // Assert
      expect(userService.userNotifier.value, isNull);
      expect(mockUserRepository.calls['deleteSession'], contains(testUser));

      // Verify stream updates no longer affect the notifier
      userStreamController.add(updatedUser);
      expect(userService.userNotifier.value, isNull);

      // Cleanup
      userStreamController.close();
    });

    test('signUp should create user and update notifier', () {
      // Arrange
      final newUser = User(name: 'NewUser', uid: 'new-uid-789');
      mockUserRepository.createdUser = testUser;

      // Act
      final result = userService.signUp(newUser);

      // Assert
      expect(result, equals(testUser));
      expect(userService.userNotifier.value, equals(testUser));
      expect(mockUserRepository.calls['createUser'], contains(newUser));
    });

    test('sessionExists should return null when no session exists', () {
      // Arrange
      mockUserRepository.sessionUser = null;

      // Act
      final result = userService.sessionExists();

      // Assert
      expect(result, isNull);
      expect(userService.userNotifier.value, isNull);
      expect(mockUserRepository.calls['sessionExists'], isNotEmpty);
      expect(mockUserRepository.calls['listenToUser'], isEmpty);
    });

    test('sessionExists should restore session and listen to updates', () {
      // Arrange
      final userStreamController = StreamController<User?>();
      mockUserRepository.sessionUser = testUser;
      mockUserRepository.userStream = userStreamController.stream;

      // Act
      final result = userService.sessionExists();

      // Assert
      expect(result, equals(testUser));
      expect(userService.userNotifier.value, equals(testUser));
      expect(mockUserRepository.calls['sessionExists'], isNotEmpty);
      expect(mockUserRepository.calls['listenToUser'], contains(testUser));

      // Test stream updates
      userStreamController.add(updatedUser);
      // Wait for the event to be processed
      addTearDown(() async {
        await userStreamController.close();
      });

      // Use microtask to let the stream event be processed
      return Future.microtask(() {
        expect(userService.userNotifier.value, equals(updatedUser));
      });
    });
  });
}
