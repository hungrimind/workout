import 'package:demo/auth/login_view.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/database_abstraction.dart';
import 'package:demo/core/locator.dart';
import 'package:demo/workout/workout_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  await locator<DatabaseAbstraction>().openDatabaseWithTables(
    [
      'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, uid INTEGER NOT NULL, admin INTEGER)',
      'CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, FOREIGN KEY (user_id) REFERENCES users(id))',
      '''
      CREATE TABLE IF NOT EXISTS exercises (
        id INTEGER PRIMARY KEY,
        name TEXT,
        reps INTEGER,
        date TEXT,
        userId INTEGER
      )
    '''
    ],
    'my_app',
  );

  locator<UserService>().sessionExists();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final UserService userService = locator<UserService>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ValueListenableBuilder(
        valueListenable: userService.userNotifier,
        builder: (context, user, child) {
          if (user == null) {
            return const LoginView();
          }
          return const WorkoutView();
        },
      ),
    );
  }
}
