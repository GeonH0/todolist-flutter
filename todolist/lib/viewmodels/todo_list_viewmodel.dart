// lib/viewmodels/todo_list_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/models/tag.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';

/// Provider 설정: HiveRepository를 주입
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return HiveTodoRepository();
});

/// Todo 리스트 상태를 관리하는 ViewModel
class TodoListViewModel extends StateNotifier<List<Todo>> {
  final TodoRepository _repository;

  TodoListViewModel(this._repository) : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _repository.fetchAllTodos();
    state = todos;
  }

  Future<void> addTodo({
    required String title,
    String? imagePath,
    List<Tag>? tags,
  }) async {
    final newTodo = Todo(
      title: title,
      imagePath: imagePath,
      tags: tags ?? <Tag>[],
    );
    await _repository.insertTodo(newTodo);
    await _loadTodos();
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    String? imagePath,
    List<Tag>? tags,
  }) async {
    final oldList = state;
    final oldTodo = oldList.firstWhere((t) => t.id == id);
    final updatedTodo = oldTodo.copyWith(
      title: title,
      imagePath: imagePath,
      tags: tags,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTodo(updatedTodo);
    await _loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteById(id);
    await _loadTodos();
  }

  Future<void> toggleCompletion(String id) async {
    final oldList = state;
    final oldTodo = oldList.firstWhere((t) => t.id == id,
        orElse: () => throw Exception('Todo not found'));
    final toggledTodo = oldTodo.copyWith(
      isCompleted: !oldTodo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTodo(toggledTodo);
    await _loadTodos();
  }
}

final todoListViewModelProvider =
    StateNotifierProvider<TodoListViewModel, List<Todo>>((ref) {
  final repo = ref.read(todoRepositoryProvider);
  return TodoListViewModel(repo);
});
