import 'package:demo/abstractions/sqlite_abstraction.dart';
import 'package:demo/create_account/create_view_model.dart';
import 'package:demo/database_page.dart';
import 'package:demo/user_service.dart';
import 'package:demo/utils/locator.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late final CreateAccountViewModel createAccountViewModel;
  late final UserService userService = locator.get<UserService>();
  late final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createAccountViewModel = CreateAccountViewModel(userService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Create Account'),
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
          valueListenable: userService.userNotifier,
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
                        createAccountViewModel.createUser(nameController.text);
                        Navigator.pop(context);
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
