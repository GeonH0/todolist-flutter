// lib/views/todo_detail_edit.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/utils/date_time_utils.dart';
import '../../models/tag.dart';
import '../../models/todo.dart';

class TodoDetailEditForm extends ConsumerWidget {
  final Todo todo;
  final TextEditingController titleController;
  final StateNotifierProvider<StateController<List<Tag>>, List<Tag>>
      selectedTagsProvider;
  final StateProvider<String?> imagePathProvider;
  final VoidCallback pickImageCallback;

  const TodoDetailEditForm({
    super.key,
    required this.todo,
    required this.titleController,
    required this.selectedTagsProvider,
    required this.imagePathProvider,
    required this.pickImageCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 현재 편집 상태에서 선택된 태그들
    final selectedTags = ref.watch(selectedTagsProvider);
    // 현재 편집 상태에서 선택된(또는 기존) 이미지 경로
    final pickedImagePath = ref.watch(imagePathProvider);
    // 전체 가능한 태그 목록 (enum)
    final availableTags = Tag.values;

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
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
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
      ],
    );
  }
}
