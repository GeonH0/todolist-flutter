// lib/views/todo_detail/todo_detail_edit_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tag.dart';
import '../../models/todo.dart';

/// TodoDetailEditForm: 수정 모드(편집)용 폼
/// - [todo]: 기존 Todo 데이터
/// - [titleController]: 제목 입력용 컨트롤러
/// - [selectedTagsProvider]: 태그 선택 상태를 관리하는 Provider
/// - [imagePathProvider]: 이미지 경로 선택 상태를 관리하는 Provider
/// - [dueDateProvider]: 마감일 선택 상태를 관리하는 Provider (DateTime? 타입)
/// - [pickImageCallback]: 이미지 선택 콜백
class TodoDetailEditForm extends ConsumerWidget {
  final Todo todo;
  final TextEditingController titleController;
  final StateNotifierProvider<StateController<List<Tag>>, List<Tag>>
      selectedTagsProvider;
  final StateProvider<String?> imagePathProvider;
  final StateProvider<DateTime?> dueDateProvider;
  final VoidCallback pickImageCallback;

  const TodoDetailEditForm({
    super.key,
    required this.todo,
    required this.titleController,
    required this.selectedTagsProvider,
    required this.imagePathProvider,
    required this.dueDateProvider,
    required this.pickImageCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 1) 현재 편집 상태에서 선택된 태그들
    final selectedTags = ref.watch(selectedTagsProvider);
    // 2) 현재 편집 상태에서 선택된(또는 기존) 이미지 경로
    final pickedImagePath = ref.watch(imagePathProvider);
    // 3) 현재 편집 상태에서 선택된(또는 기존) 마감일
    final pickedDueDate = ref.watch(dueDateProvider) ?? todo.dueDate;

    // 4) 전체 가능한 태그 목록 (enum)
    final availableTags = Tag.values;

    Future<void> pickDueDate() async {
      final initialDate = pickedDueDate ?? DateTime.now();
      final firstDate = DateTime(2000);
      final lastDate = DateTime(2100);

      final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (newDate != null) {
        ref.read(dueDateProvider.notifier).state = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1) 이미지 선택/편집
        GestureDetector(
          onTap: pickImageCallback,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: pickedImagePath == null
                ? (todo.imagePath == null
                    ? Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(todo.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(pickedImagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // 2) 제목 입력
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),

        // 3) 태그 선택 (ChoiceChip)
        const Text(
          '태그 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: availableTags.map((Tag tag) {
            final tagName = tag.name;
            final isSelected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tagName),
              selected: isSelected,
              onSelected: (_) {
                if (isSelected) {
                  // 이미 선택된 태그면 해제
                  ref.read(selectedTagsProvider.notifier).state =
                      selectedTags.where((t) => t != tag).toList();
                } else {
                  // 아니면 추가
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
        const SizedBox(height: 24),

        // 4) 마감일 선택
        const Text(
          '마감일 설정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.onSurface),
                const SizedBox(width: 12),
                Text(
                  pickedDueDate != null
                      ? '${pickedDueDate.year}-${pickedDueDate.month.toString().padLeft(2, '0')}-${pickedDueDate.day.toString().padLeft(2, '0')}'
                      : '마감일 없음',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
