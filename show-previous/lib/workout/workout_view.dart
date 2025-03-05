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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...workoutViewModel.exerciseSets.entries
                .map((entry) => ExerciseCard(
                      name: entry.key,
                      exercise: entry.value,
                      workoutViewModel: workoutViewModel,
                    )),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    workoutViewModel.finishWorkout();
                  },
                  child: const Text('Finish Workout'),
                ),
                const SizedBox(width: 16),
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
          ],
        ),
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  ExerciseCard({
    super.key,
    required this.exercise,
    required this.name,
    required this.workoutViewModel,
  });

  final ValueNotifier<List<int>> exercise;
  final String name;
  final WorkoutViewModel workoutViewModel;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final TextEditingController repsController = TextEditingController();

  @override
  void dispose() {
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.exercise,
      builder: (context, value, child) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.all(8),
          color: Colors.grey[50],
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
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: widget
                          .workoutViewModel.previousSessionSets[widget.name]!,
                      builder: (context, previousSets, _) {
                        if (previousSets.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(value.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Set ${index + 1}: ${value[index]} reps',
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
                                  widget.workoutViewModel
                                      .removeSet(widget.name, index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter reps',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        if (repsController.text.isNotEmpty) {
                          widget.workoutViewModel.addSet(
                              widget.name, int.parse(repsController.text));
                          repsController.clear();
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
