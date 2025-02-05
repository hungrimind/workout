import 'package:demo/auth/user_service.dart';
import 'package:demo/core/database_view.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/workout/workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:demo/core/database_abstraction.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  late final WorkoutViewModel workoutViewModel = WorkoutViewModel(
    userService: locator<UserService>(),
    database: locator<DatabaseAbstraction>(),
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
                  builder: (context) => DatabasePage(),
                ),
              );
            },
            child: const Text('Show Database'),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Exercise',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Previous Reps',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Current Reps',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Space for save button
              ],
            ),
          ),
          ...workoutViewModel.exercises
              .map((exercise) => _buildExerciseCard(exercise)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              workoutViewModel.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String exercise) {
    TextEditingController repsController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              exercise,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: workoutViewModel.previousReps[exercise]!,
              builder: (context, previousReps, _) {
                return Text('$previousReps');
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: workoutViewModel.currentReps[exercise]!,
              builder: (context, currentReps, _) {
                return TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  controller: repsController,
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final reps = int.tryParse(repsController.text) ?? 0;
              if (reps > 0) {
                workoutViewModel.saveExercise(exercise, reps);
              }
              repsController.clear();
            },
          ),
        ],
      ),
    );
  }
}
