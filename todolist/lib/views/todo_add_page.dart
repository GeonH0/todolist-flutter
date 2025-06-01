// lib/views/todo_add_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../models/todo_draft.dart';
import '../repositories/todo_draft_repository.dart';
import '../models/tag.dart';
import '../viewmodels/todo_list_viewmodel.dart';

/// 이미지 경로를 보관하는 Provider
final todoAddImagePathProvider = StateProvider<String?>((ref) => null);

/// 선택된 문자열 태그를 보관하는 Provider
final selectedTagsProvider = StateProvider<List<String>>((ref) => []);

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends ConsumerState<TodoAddPage> {
  final TextEditingController _titleController = TextEditingController();
  late final TodoDraftRepository _draftRepo;

  // 미리 정의된 태그 목록
  final List<String> _availableTags = ['work', 'personal', 'study', 'shopping'];

  @override
  void initState() {
    super.initState();
    _draftRepo = HiveTodoDraftRepository();

    // → 기존: ref.read(selectedTagsProvider.notifier).state = [];
    //          ref.read(todoAddImagePathProvider.notifier).state = null;

    // 수정: 위젯 트리가 완전히 그려진 다음에 Provider를 초기화하도록 연기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedTagsProvider.notifier).state = [];
      ref.read(todoAddImagePathProvider.notifier).state = null;
      _checkAndLoadDraft();
    });
  }

  /// 드래프트가 있으면 불러올지 묻기
  Future<void> _checkAndLoadDraft() async {
    final draft = await _draftRepo.loadDraft();
    if (draft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('임시 저장된 내용이 있습니다'),
              content: const Text('이전에 작성하던 Todo를 불러오시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    _loadDraftToUI(draft);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('불러오기'),
                ),
                TextButton(
                  onPressed: () async {
                    await _draftRepo.deleteDraft();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('삭제하고 새로 작성'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  /// 드래프트를 화면에 반영
  void _loadDraftToUI(TodoDraft draft) {
    _titleController.text = draft.title;
    ref.read(todoAddImagePathProvider.notifier).state = draft.imagePath;
    final stringTags = draft.tags.map((t) => t.name).toList();
    ref.read(selectedTagsProvider.notifier).state = stringTags;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// 뒤로 가기 누를 때 자동 임시 저장
  Future<bool> _onWillPop() async {
    await _saveDraft();
    return true;
  }

  /// 갤러리에서 이미지를 선택하여 Provider에 저장
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      ref.read(todoAddImagePathProvider.notifier).state = picked.path;
    }
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text.trim();
    final imagePath = ref.read(todoAddImagePathProvider);
    final selectedTags = ref.read(selectedTagsProvider);

    // 1) 제목, 이미지, 태그 모두 비어 있으면 저장하지 않음
    if (title.isEmpty && imagePath == null && selectedTags.isEmpty) {
      return;
    }

    // 2) 하나라도 입력된 내용이 있으면 드래프트 저장
    final draft = TodoDraft(
      title: title,
      imagePath: imagePath,
      tags: selectedTags.map(_stringToTag).toList(),
    );
    await _draftRepo.saveDraft(draft);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('자동으로 임시 저장되었습니다.')),
    );
  }

  /// 실제로 Todo를 저장하고 드래프트 삭제 + Provider 초기화
  Future<void> _saveTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목은 필수 입력 항목입니다.')),
      );
      return;
    }

    final selectedEnumTags =
        ref.read(selectedTagsProvider).map(_stringToTag).toList();
    final imagePath = ref.read(todoAddImagePathProvider);

    // 1) ViewModel을 통해 Hive에 새 Todo 추가
    await ref.read(todoListViewModelProvider.notifier).addTodo(
          title: title,
          imagePath: imagePath,
          tags: selectedEnumTags,
        );

    // 2) 정식 저장 후 드래프트 삭제
    await _draftRepo.deleteDraft();

    // 3) 저장 완료 시 Provider들 초기화
    ref.read(selectedTagsProvider.notifier).state = [];
    ref.read(todoAddImagePathProvider.notifier).state = null;

    // 4) 화면 닫기
    if (mounted) {
      context.pop();
    }
  }

  /// 문자열을 Tag enum으로 변환
  Tag _stringToTag(String raw) {
    switch (raw) {
      case 'work':
        return Tag.work;
      case 'personal':
        return Tag.personal;
      case 'study':
        return Tag.study;
      case 'shopping':
        return Tag.shopping;
      default:
        return Tag.work;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final pickedImagePath = ref.watch(todoAddImagePathProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('새로운 할 일 추가'),
          backgroundColor: colorScheme.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) 이미지 선택 영역
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: pickedImagePath == null
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(pickedImagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 2) 제목 입력 TextField
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // 3) 태그 선택 영역 (ChoiceChip)
              const Text(
                '태그 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) {
                      if (isSelected) {
                        ref.read(selectedTagsProvider.notifier).state =
                            selectedTags.where((t) => t != tag).toList();
                      } else {
                        ref.read(selectedTagsProvider.notifier).state = [
                          ...selectedTags,
                          tag,
                        ];
                      }
                    },
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // 4) 저장 버튼
              ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '저장',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
