// lib/repositories/todo_repository.dart

import 'package:hive/hive.dart';
import '../models/todo.dart';

/// Todo CRUD 기능을 정의한 추상 인터페이스
abstract class TodoRepository {
  Future<List<Todo>> fetchAllTodos();
  Future<void> insertTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteById(String id);
}

class HiveTodoRepository implements TodoRepository {
  static const String _boxName = 'todoBox';
  Box<Todo>? _box;

  HiveTodoRepository() {
    _init();
  }

  /// 생성자에서 한 번만 박스를 열어두도록 시도합니다.
  Future<void> _init() async {
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Todo>(_boxName);
    } else {
      _box = await Hive.openBox<Todo>(_boxName);
    }
  }

  /// 내부에서 항상 박스 인스턴스를 가져오는 헬퍼 메서드
  Future<Box<Todo>> _getBox() async {
    if (_box == null) {
      _box = await Hive.openBox<Todo>(_boxName);
    }
    return _box!;
  }

  @override
  Future<List<Todo>> fetchAllTodos() async {
    final box = await _getBox();
    // Hive 박스에 저장된 모든 Todo 객체를 리스트로 반환
    return box.values.toList();
  }

  @override
  Future<void> insertTodo(Todo todo) async {
    final box = await _getBox();
    // add()는 자동으로 내부 키를 생성하여 객체를 저장합니다.
    await box.add(todo);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final box = await _getBox();

    final idx = box.values.toList().indexWhere((t) => t.id == todo.id);
    if (idx == -1) {
      // 해당 id가 없으면 아무 동작도 하지 않음
      return;
    }

    final key = box.keyAt(idx);
    await box.put(key, todo);
  }

  @override
  Future<void> deleteById(String id) async {
    final box = await _getBox();
    final idx = box.values.toList().indexWhere((t) => t.id == id);
    if (idx == -1) {
      return;
    }
    final key = box.keyAt(idx);
    await box.delete(key);
  }
}
