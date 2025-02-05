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
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder(
            valueListenable: workoutViewModel.userNotifier,
            builder: (context, user, child) {
              return Text(
                'Welcome ${user?.name}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          const SizedBox(height: 20),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: workoutViewModel.previousReps[exercise]!,
                    builder: (context, previousReps, _) {
                      return Text('Previous: $previousReps reps');
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
                          labelText: 'Current Reps',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final reps = int.tryParse(value) ?? 0;
                          workoutViewModel.updateReps(exercise, reps);
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    final reps = workoutViewModel.currentReps[exercise]!.value;
                    if (reps > 0) {
                      workoutViewModel.saveExercise(exercise, reps);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
