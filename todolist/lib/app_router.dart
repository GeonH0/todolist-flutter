// lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todolist/views/todo_add_page.dart';
import 'package:todolist/views/todo_list_tab.dart';
import 'package:todolist/views/user_info_tab.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/todos',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        final currentIndex = location.startsWith('/user') ? 1 : 0;

        // 하단탭은 /todos 또는 /user일 때만 표시
        final showBottomNav = location == '/todos' || location == '/user';
        // FAB은 /todos 메인 화면일 때만 표시
        final showFabInLocation = location == '/todos';

        // 키보드가 떠 있는지 여부 확인
        final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        return Scaffold(
          body: child,
          bottomNavigationBar: showBottomNav
              ? BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (newIndex) {
                    if (newIndex == 0) {
                      context.go('/todos');
                    } else {
                      context.go('/user');
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list_alt),
                      label: 'Todo List',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'User Info',
                    ),
                  ],
                  selectedItemColor: Colors.tealAccent[700],
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Colors.grey[900],
                  type: BottomNavigationBarType.fixed,
                )
              : null,

          // 키보드가 열려 있지 않고, 현재 위치가 /todos라면 FAB 표시
          floatingActionButton: (showFabInLocation && !isKeyboardOpen)
              ? FloatingActionButton(
                  backgroundColor: Colors.tealAccent[700],
                  child: const Icon(Icons.add),
                  onPressed: () {
                    context.go('/todos/add');
                  },
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
      routes: [
        GoRoute(
          path: '/todos',
          builder: (context, state) => const TodoListTab(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const TodoAddPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => const TodoListTab(),
            ),
          ],
        ),
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserInfoTab(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
