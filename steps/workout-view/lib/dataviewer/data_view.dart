import 'package:demo/auth/user_repository.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/dataviewer/data_view_model.dart';
import 'package:demo/core/locator.dart';
import 'package:flutter/material.dart';

import '../../auth/user.dart';

class DataView extends StatefulWidget {
  const DataView({super.key});

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  late final DataViewModel databaseViewModel = DataViewModel(
    databaseAbstraction: locator<DatabaseAbstraction>(),
    userRepository: locator<UserRepository>(),
  );

  @override
  void initState() {
    super.initState();
    databaseViewModel.init();
  }

  @override
  void dispose() {
    databaseViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database View'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<List<User>>(
              valueListenable: databaseViewModel.users,
              builder: (context, users, _) {
                return _buildUsersSection(theme, users);
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<AuthSession>>(
              valueListenable: databaseViewModel.authSessions,
              builder: (context, sessions, _) {
                return _buildAuthSessionsSection(theme, sessions);
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<WorkoutSession>>(
              valueListenable: databaseViewModel.workoutSessions,
              builder: (context, sessions, _) {
                return _buildWorkoutSessionsSection(theme, sessions);
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<ExerciseSet>>(
              valueListenable: databaseViewModel.exerciseSets,
              builder: (context, sets, _) {
                return _buildExerciseSetsSection(theme, sets);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection(ThemeData theme, List<User> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Users',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (users.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.people_outline,
            message: 'No users in database',
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('UID')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user.id.toString())),
                      DataCell(Text(user.name)),
                      DataCell(Text(user.uid)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            databaseViewModel.deleteUser(user);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAuthSessionsSection(
      ThemeData theme, List<AuthSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auth Sessions',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.schedule_outlined,
            message: 'No auth sessions in database',
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('User Name')),
                ],
                rows: sessions.map((session) {
                  return DataRow(
                    cells: [
                      DataCell(Text(session.id.toString())),
                      DataCell(Text(session.userId.toString())),
                      DataCell(Text(session.userName)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutSessionsSection(
      ThemeData theme, List<WorkoutSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Sessions',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.fitness_center_outlined,
            message: 'No workout sessions in database',
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Date')),
                ],
                rows: sessions.map((session) {
                  return DataRow(
                    cells: [
                      DataCell(Text(session.id.toString())),
                      DataCell(Text(session.userId.toString())),
                      DataCell(Text(session.userName)),
                      DataCell(Text(_formatDate(session.date))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseSetsSection(ThemeData theme, List<ExerciseSet> sets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Sets',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (sets.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.fitness_center_outlined,
            message: 'No exercise sets in database',
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Session ID')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Exercise')),
                  DataColumn(label: Text('Set #')),
                  DataColumn(label: Text('Reps')),
                  DataColumn(label: Text('Date')),
                ],
                rows: sets.map((set) {
                  return DataRow(
                    cells: [
                      DataCell(Text(set.id.toString())),
                      DataCell(Text(set.sessionId.toString())),
                      DataCell(Text('${set.userName}\n(ID: ${set.userId})')),
                      DataCell(Text(set.exerciseName)),
                      DataCell(Text(set.setNumber.toString())),
                      DataCell(Text(set.reps.toString())),
                      DataCell(Text(_formatDate(set.date))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyView(
    ThemeData theme, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.secondary),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
