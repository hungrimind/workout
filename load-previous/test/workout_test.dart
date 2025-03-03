import 'package:demo/auth/user.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:demo/workout/workout_view.dart';
import 'package:demo/workout/workout_view_model.dart';
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
  Map<String, ValueNotifier<List<int>>> exerciseSets = {
    'Squat': ValueNotifier<List<int>>([10, 12, 15]),
    'Deadlift': ValueNotifier<List<int>>([8, 10]),
  };

  bool createWorkoutSessionCalled = false;
  bool saveExerciseSetCalled = false;
  int? lastSessionId;

  // Test data for previous workouts
  List<Map<String, dynamic>> previousWorkouts = [];
  Map<String, List<Map<String, dynamic>>> exerciseSetsData = {};

  MockWorkoutRepository() {
    // Initialize with empty previous workouts to avoid null check errors
    previousWorkouts = [];

    // Initialize with empty exercise sets for all standard exercises
    final exercises = ['Push-ups', 'Pull-ups', 'Sit-ups', 'Squats'];
    for (var exercise in exercises) {
      exerciseSetsData[exercise] = [];
    }
  }

  @override
  Future<int?> createWorkoutSession(int userId, DateTime date) async {
    createWorkoutSessionCalled = true;
    lastSessionId = 123;
    return lastSessionId;
  }

  @override
  bool saveExerciseSet(
      int sessionId, String exerciseName, int reps, int setNumber) {
    saveExerciseSetCalled = true;
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseSets(
      int workoutId, String exerciseName) async {
    return exerciseSetsData[exerciseName] ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> getPreviousWorkoutSessions(
      int userId) async {
    return previousWorkouts;
  }
}

void main() {
  late final FakeUserService fakeUserService = FakeUserService();
  late final MockWorkoutRepository mockWorkoutRepository =
      MockWorkoutRepository();

  setUp(() {
    locator.registerSingleton<UserService>(fakeUserService);
    locator.registerSingleton<WorkoutRepository>(mockWorkoutRepository);

    // Reset state between tests
    fakeUserService.deleteSessionCalled = false;
    mockWorkoutRepository.createWorkoutSessionCalled = false;
    mockWorkoutRepository.saveExerciseSetCalled = false;
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

    testWidgets('Displays exercise cards for each exercise set',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Verify ExerciseCards are displayed
      expect(find.byType(ExerciseCard), findsNWidgets(4));

      // Check the exercise names are displayed
      expect(find.text('Push-ups'), findsOneWidget);
      expect(find.text('Pull-ups'), findsOneWidget);
      expect(find.text('Sit-ups'), findsOneWidget);
      expect(find.text('Squats'), findsOneWidget);

      // Verify each card has the text field for reps
      expect(find.widgetWithText(TextField, 'Enter reps'), findsNWidgets(4));

      // Verify add buttons are present
      expect(find.byIcon(Icons.add), findsNWidgets(4));
    });

    testWidgets('Shows snackbar and calls deleteSession when logging out',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Find the logout button
      final logoutButton = find.text('Logout');
      expect(logoutButton, findsOneWidget);

      // Ensure the button is visible by scrolling to it
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(logoutButton);
      await tester.pump();

      // Verify snackbar is shown
      expect(find.text('Logged out'), findsOneWidget);

      // Verify deleteSession was called
      expect(fakeUserService.deleteSessionCalled, true);
    });

    testWidgets('Finish Workout button exists in the UI', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Verify the button exists
      final finishButton = find.text('Finish Workout');
      expect(finishButton, findsOneWidget);
    });

    testWidgets('Can add and remove exercise sets', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WorkoutView(),
      ));

      // Verify initial state
      final firstExercise = 'Push-ups';
      expect(find.text(firstExercise), findsOneWidget);

      // Initially, there should be no sets displayed for Push-ups
      expect(find.textContaining('Set 1: '), findsNothing);

      // Find the text field for the first exercise card
      final textField = find.widgetWithText(TextField, 'Enter reps').first;

      // Enter a rep count
      await tester.enterText(textField, '10');
      await tester.pump();

      // Find and tap the add button for the first exercise
      final addButton = find
          .descendant(
            of: find.ancestor(
              of: find.text(firstExercise),
              matching: find.byType(ExerciseCard),
            ),
            matching: find.byIcon(Icons.add),
          )
          .first;

      await tester.tap(addButton);
      await tester.pump();

      // Verify a new set was added
      expect(find.text('Set 1: 10 reps'), findsOneWidget);

      // Add one more set
      await tester.enterText(textField, '15');
      await tester.pump();
      await tester.tap(addButton);
      await tester.pump();

      // Verify both sets are now displayed
      expect(find.text('Set 1: 10 reps'), findsOneWidget);
      expect(find.text('Set 2: 15 reps'), findsOneWidget);

      // Find and tap the remove button for the first set
      final removeButton = find
          .descendant(
            of: find.ancestor(
              of: find.text('Set 1: 10 reps'),
              matching: find.byType(Row),
            ),
            matching: find.byIcon(Icons.close),
          )
          .first;

      await tester.tap(removeButton);
      await tester.pump();

      // Verify the first set was removed and the second set became the first
      expect(find.text('Set 1: 10 reps'), findsNothing);
      expect(find.text('Set 1: 15 reps'), findsOneWidget);
      expect(find.text('Set 2: 15 reps'), findsNothing);
    });
  });

  test('WorkoutViewModel.finishWorkout saves workout and clears sets',
      () async {
    // Make sure user exists and has an ID
    fakeUserService.signIn('Test User');
    expect(fakeUserService.userNotifier.value, isNotNull);
    expect(fakeUserService.userNotifier.value!.id, isNotNull);

    // Create a ViewModel directly
    final viewModel = WorkoutViewModel(
      userService: fakeUserService,
      workoutRepository: mockWorkoutRepository,
    );

    // Add sets for two exercises
    viewModel.addSet('Push-ups', 10);
    viewModel.addSet('Pull-ups', 15);

    // Verify sets were added
    expect(viewModel.exerciseSets['Push-ups']!.value.length, 1);
    expect(viewModel.exerciseSets['Pull-ups']!.value.length, 1);

    // Call finishWorkout
    await viewModel.finishWorkout();

    // Verify repository methods were called
    expect(mockWorkoutRepository.createWorkoutSessionCalled, true,
        reason: 'createWorkoutSession should be called');
    expect(mockWorkoutRepository.saveExerciseSetCalled, true,
        reason: 'saveExerciseSet should be called');

    // Verify sets were cleared
    expect(viewModel.exerciseSets['Push-ups']!.value.length, 0,
        reason: 'Push-ups sets should be cleared');
    expect(viewModel.exerciseSets['Pull-ups']!.value.length, 0,
        reason: 'Pull-ups sets should be cleared');
  });
}
