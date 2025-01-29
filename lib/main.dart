import 'package:demo/abstractions/sqlite_abstraction.dart';
import 'package:demo/home/home_page.dart';
import 'package:demo/login/login_page.dart';
import 'package:demo/ui_library/theme/app_theme.dart';
import 'package:demo/user_service.dart';
import 'package:demo/utils/locator.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  await locator<SqliteAbstraction>().loadSqlite();
  locator<UserService>().checkForSession();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final UserService userService = locator.get<UserService>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(Brightness.light),
      darkTheme: AppTheme.buildTheme(Brightness.dark),
      home: ValueListenableBuilder(
        valueListenable: userService.userNotifier,
        builder: (context, user, child) {
          if (user == null) {
            return const LoginPage(title: 'Login');
          }
          return const HomePage();
        },
      ),
    );
  }
}
