import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:demo/workout/workout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserService extends Fake implements UserService {
  final _userNotifier = ValueNotifier<User?>(
    User(id: 1, name: 'Test User', uid: 'test-uid'),
  );
  bool deleteSessionCalled = false;

  @override
  ValueNotifier<User?> get userNotifier => _userNotifier;

  @override
  void signOut() {
    deleteSessionCalled = true;
    _userNotifier.value = null;
  }

  @override
  User? signIn(String name) {
    final user = User(id: 1, name: name, uid: 'test-uid');
    _userNotifier.value = user;
    return user;
  }

  @override
  User? signUp(User user) {
    _userNotifier.value = user;
    return user;
  }

  @override
  User? sessionExists() {
    return _userNotifier.value;
  }
}

class MockWorkoutRepository implements WorkoutRepository {
  @override
  Future<int?> createWorkoutSession(int userId, DateTime date) async {
    return 123;
  }

  @override
  bool saveExerciseSet(
      int sessionId, String exerciseName, int reps, int setNumber) {
    return true;
  }
}

void main() {
  late final FakeUserService fakeUserService = FakeUserService();
  late final MockWorkoutRepository mockWorkoutRepository =
      MockWorkoutRepository();

  setUp(() {
    locator.registerSingleton<UserService>(fakeUserService);
    locator.registerSingleton<WorkoutRepository>(mockWorkoutRepository);
  });

  tearDown(() {
    locator.reset();
  });

  group('HomeView', () {
    testWidgets('Check that the Appbar has the correct title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Verify text field is cleared (success case)
      expect(find.text('Workout Tracker'), findsOneWidget);
    });
    testWidgets('Shows snackbar and calls deleteSession when logging out',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Verify initial state shows user name
      expect(find.text('Welcome Test User'), findsOneWidget);

      // Tap logout button
      await tester.tap(find.text('Logout'));
      await tester.pump();

      // Verify snackbar is shown
      expect(find.text('Logged out'), findsOneWidget);

      // Verify deleteSession was called
      expect(fakeUserService.deleteSessionCalled, true);
    });
  });
}
