// lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todolist/views/todo_list_tab.dart';
import 'package:todolist/views/user_info_tab.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/todos', // 앱 시작 시 Todo 탭을 먼저 보여줌
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        // 현재 URL(location) 기반으로 하단 탭 인덱스 계산
        final location = state.uri.toString();
        // '/todos' 또는 '/todos/...' 이면 index = 0, '/user' 이면 index = 1
        final currentIndex = location.startsWith('/user') ? 1 : 0;

        return Scaffold(
          body: child, // 하위 라우트(탭 콘텐츠) 그대로 보여 줌
          bottomNavigationBar: BottomNavigationBar(
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
          ),

          // ─── FloatingActionButton: Todo 탭에서만 보이도록 조건부 배치 ───
          floatingActionButton: currentIndex == 0
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
        // 1) /todos (Todo List 화면)
        GoRoute(
          path: '/todos',
          builder: (context, state) => const TodoListTab(),
          routes: [
            // 1-1) /todos/add (Todo 추가 페이지)
            GoRoute(
              path: 'add',
              builder: (context, state) => const TodoListTab(),
            ),
            // 1-2) /todos/:id (Todo 상세 페이지)
            GoRoute(
              path: ':id',
              builder: (context, state) => const TodoListTab(),
            ),
          ],
        ),

        // 2) /user (User Info 화면)
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
