// lib/repositories/todo_draft_repository.dart

import 'package:hive/hive.dart';
import '../models/todo_draft.dart';

/// 1) 추상 인터페이스 정의
abstract class TodoDraftRepository {
  Future<void> init();
  Future<TodoDraft?> loadDraft();
  Future<void> saveDraft(TodoDraft draft);
  Future<void> deleteDraft();
}

/// 2) Hive 기반 구현체
class HiveTodoDraftRepository implements TodoDraftRepository {
  static const String _boxName = 'todoDraftBox';
  static const String _draftKey = 'draft';
  Box<TodoDraft>? _box;

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<TodoDraft>(_boxName);
    } else {
      _box = Hive.box<TodoDraft>(_boxName);
    }
  }

  @override
  Future<TodoDraft?> loadDraft() async {
    _box ??= await Hive.openBox<TodoDraft>(_boxName);
    return _box!.get(_draftKey);
  }

  @override
  Future<void> saveDraft(TodoDraft draft) async {
    _box ??= await Hive.openBox<TodoDraft>(_boxName);
    await _box!.put(_draftKey, draft);
  }

  @override
  Future<void> deleteDraft() async {
    _box ??= await Hive.openBox<TodoDraft>(_boxName);
    await _box!.delete(_draftKey);
  }
}
