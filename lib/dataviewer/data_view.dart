import 'package:demo/auth/user_repository.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/dataviewer/data_view_model.dart';
import 'package:demo/core/locator.dart';
import 'package:flutter/material.dart';

import '../auth/user.dart';

class DataView extends StatefulWidget {
  const DataView({super.key});

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  late final DataViewModel databaseViewModel = DataViewModel(
    userRepository: locator<UserRepository>(),
    databaseAbstraction: locator<DatabaseAbstraction>(),
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
            ValueListenableBuilder<List<int>>(
              valueListenable: databaseViewModel.sessions,
              builder: (context, sessions, _) {
                return _buildSessionsSection(theme, sessions);
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<User>>(
              valueListenable: databaseViewModel.users,
              builder: (context, users, _) {
                return _buildUsersSection(theme, users);
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<ExerciseRecord>>(
              valueListenable: databaseViewModel.exercises,
              builder: (context, exercises, _) {
                return _buildExercisesSection(theme, exercises);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSection(ThemeData theme, List<int> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sessions',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.schedule_outlined,
            message: 'No sessions in database',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                child: ListTile(
                  title: Text(
                    'Session user_id: $session',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              );
            },
          ),
      ],
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'ID: ${user.id} - UID: ${user.uid}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    databaseViewModel.deleteUser(user);
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildExercisesSection(
      ThemeData theme, List<ExerciseRecord> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Records',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (exercises.isEmpty)
          _buildEmptyView(
            theme,
            icon: Icons.fitness_center_outlined,
            message: 'No exercise records in database',
          )
        else
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Exercise',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Reps',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(exercise.userName),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(exercise.exercise),
                          ),
                          Expanded(
                            child: Text(exercise.reps.toString()),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatDate(exercise.timestamp),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
