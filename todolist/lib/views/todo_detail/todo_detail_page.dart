// lib/views/todo_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:todolist/models/tag.dart';
import 'package:todolist/viewmodels/todo_list_viewmodel.dart';
import 'package:todolist/views/todo_detail/todo_detail_read.dart';
import 'package:todolist/views/todo_detail/todo_detail_edit.dart';

/// TodoDetailPage의 “읽기 전용/수정 모드” 상태를 관리하는 Provider
final todoDetailEditingProvider = StateProvider<bool>((ref) => false);

class TodoDetailPage extends ConsumerStatefulWidget {
  final String todoId;
  const TodoDetailPage({
    super.key,
    required this.todoId,
  });

  @override
  ConsumerState<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends ConsumerState<TodoDetailPage> {
  late final TextEditingController _titleController;

  /// 수정 중인 태그 목록을 관리할 Provider
  late final StateNotifierProvider<StateController<List<Tag>>, List<Tag>>
      _selectedTagsProvider;

  /// 수정 중인 이미지 경로를 관리할 Provider
  late final StateProvider<String?> _imagePathProvider;

  @override
  void initState() {
    super.initState();

    // 처음 진입할 때 ViewModel에서 Todo를 꺼내와 초기값 세팅
    final todoList = ref.read(todoListViewModelProvider);
    final todo = todoList.firstWhere(
      (t) => t.id == widget.todoId,
      orElse: () => throw Exception('Todo not found'),
    );

    _titleController = TextEditingController(text: todo.title);

    // “수정 모드”에서 사용될 태그 상태 초기화
    _selectedTagsProvider =
        StateNotifierProvider<StateController<List<Tag>>, List<Tag>>(
      (ref) => StateController<List<Tag>>(todo.tags),
    );

    // “수정 모드”에서 사용될 이미지 경로 상태 초기화
    _imagePathProvider = StateProvider<String?>((ref) => todo.imagePath);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // 수정용 프로바이더에 경로 저장
      ref.read(_imagePathProvider.notifier).state = picked.path;
    }
  }

  /// “저장” 버튼을 눌렀을 때: ViewModel에 업데이트하고, 수정 모드를 해제
  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목은 필수 입력 항목입니다.')),
      );
      return;
    }

    final selectedTags = ref.read(_selectedTagsProvider);
    final imagePath = ref.read(_imagePathProvider);

    await ref.read(todoListViewModelProvider.notifier).updateTodo(
          id: widget.todoId,
          title: title,
          imagePath: imagePath,
          tags: selectedTags,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다.')),
    );
    ref.read(todoDetailEditingProvider.notifier).state = false;
  }

  /// “삭제” 아이콘을 눌렀을 때: 확인 다이얼로그 후 삭제 → /todos 로 이동
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('정말 삭제하시겠습니까?'),
              content: const Text('이 작업은 되돌릴 수 없습니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('삭제', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      await ref
          .read(todoListViewModelProvider.notifier)
          .deleteTodo(widget.todoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
      // /todos 경로로 강제 이동
      context.go('/todos');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel의 현재 리스트를 구독
    final allTodos = ref.watch(todoListViewModelProvider);

    // 이미 삭제되었거나 없는 ID라면 즉시 /todos로 리다이렉트
    final matching = allTodos.where((t) => t.id == widget.todoId).toList();
    if (matching.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/todos');
      });
      return const SizedBox.shrink();
    }

    final todo = matching.first;
    final colorScheme = Theme.of(context).colorScheme;

    // “읽기 전용 ↔ 수정 모드” 값을 Provider에서 가져옴
    final isEditing = ref.watch(todoDetailEditingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Todo 수정' : 'Todo 상세'),
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEditing) {
              // 수정 모드 취소 → 읽기 모드로 전환
              ref.read(todoDetailEditingProvider.notifier).state = false;
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (!isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // 수정 모드로 전환
                ref.read(todoDetailEditingProvider.notifier).state = true;
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: isEditing
            ? TodoDetailEditForm(
                todo: todo,
                titleController: _titleController,
                selectedTagsProvider: _selectedTagsProvider,
                imagePathProvider: _imagePathProvider,
                pickImageCallback: _pickImage,
              )
            : TodoDetailReadView(
                todo: todo,
              ),
      ),
    );
  }
}
