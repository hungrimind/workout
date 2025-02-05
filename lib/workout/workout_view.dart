import 'package:demo/auth/user_service.dart';
import 'package:demo/dataviewer/data_view.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/workout/workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        elevation: 0,
        title: const Text(
          'Workout Tracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataView()),
              );
            },
            child: const Text('Show Database'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...workoutViewModel.exercises.map(_buildExerciseCard),
          const SizedBox(height: 20),
          Center(
            child: _buildFinishButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String exercise) {
    final repsController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable:
                        workoutViewModel.previousSessionSets[exercise]!,
                    builder: (context, previousSets, _) {
                      if (previousSets.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Previous: ${previousSets.join(", ")} reps',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: workoutViewModel.exerciseSets[exercise]!,
                builder: (context, sets, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sets.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(sets.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 12),
                                  decoration: BoxDecoration(
                                    color: _getSetColor(
                                      sets[index],
                                      workoutViewModel
                                          .previousSessionSets[exercise]!.value,
                                      index,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Set ${index + 1}: ${sets[index]} reps',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.black54,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          workoutViewModel.removeSet(
                                              exercise, index);
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter reps',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              final reps =
                                  int.tryParse(repsController.text) ?? 0;
                              if (reps > 0) {
                                workoutViewModel.addSet(exercise, reps);
                                repsController.clear();
                              }
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.green,
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return TextButton(
      onPressed: () async {
        await workoutViewModel.finishWorkout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout completed!')),
          );
        }
      },
      child: const Text(
        'Finish',
      ),
    );
  }

  Color _getSetColor(int currentReps, List<int> previousSets, int setIndex) {
    // If there are no previous sets or this is a new set number, it's an improvement
    if (previousSets.isEmpty || setIndex >= previousSets.length) {
      return Colors.green.withOpacity(0.2);
    }

    // Compare with the corresponding set from previous session
    if (currentReps >= previousSets[setIndex]) {
      return Colors.green.withOpacity(0.2);
    } else {
      return Colors.red.withOpacity(0.2);
    }
  }
}
