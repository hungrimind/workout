import 'package:demo/auth/user_service.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/dataviewer/data_view.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:demo/workout/workout_view_model.dart';
import 'package:flutter/material.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  late final WorkoutViewModel workoutViewModel = WorkoutViewModel(
    userService: locator<UserService>(),
    workoutRepository: locator<WorkoutRepository>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Workout Tracker'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataView(),
                ),
              );
            },
            child: const Text('Show Database'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...workoutViewModel.exerciseSets.entries
                  .map((entry) => ExerciseCard(
                        name: entry.key,
                        exercise: entry.value,
                      )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  workoutViewModel.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged out'),
                    ),
                  );
                },
                child: Text('Logout'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  ExerciseCard({
    super.key,
    required this.exercise,
    required this.name,
  });

  final ValueNotifier<List<int>> exercise;
  final String name;
  final TextEditingController repsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: exercise,
      builder: (context, value, child) {
        return Text('$name: $value');
      },
    );
  }
}
