import 'package:demo/auth/user_repository.dart';
import 'package:demo/auth/user_service.dart';
import 'package:demo/core/abstractions/database_abstraction.dart';
import 'package:demo/workout/workout_repository.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DatabaseAbstraction());

  locator.registerLazySingleton(
    () => UserService(
      userRepository: locator.get<UserRepository>(),
    ),
  );

  locator.registerLazySingleton(
    () => UserRepository(
      databaseAbstraction: locator.get<DatabaseAbstraction>(),
    ),
  );

  locator.registerLazySingleton(
    () => WorkoutRepository(
      databaseAbstraction: locator.get<DatabaseAbstraction>(),
    ),
  );
}
