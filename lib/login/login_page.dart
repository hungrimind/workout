import 'package:demo/abstractions/sqlite_abstraction.dart';
import 'package:demo/create_account/create_page.dart';
import 'package:demo/database_page.dart';
import 'package:demo/user_service.dart';
import 'package:demo/utils/locator.dart';
import 'package:flutter/material.dart';

import 'login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel loginViewModel = LoginViewModel(
    userService: locator<UserService>(),
  );

  late final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DatabasePage(
                    sqliteAbstraction: locator<SqliteAbstraction>(),
                  ),
                ),
              );
            },
            child: const Text('View Database'),
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: loginViewModel.userNotifier,
          builder: (context, user, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          loginViewModel.login(nameController.text);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAccountPage(),
                          ),
                        );
                      },
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
