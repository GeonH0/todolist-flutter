import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/app_router.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/theme/app_theme.dart';
import 'package:todolist/views/user_info_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todoBox');
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('userBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
