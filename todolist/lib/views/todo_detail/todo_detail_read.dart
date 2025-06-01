// lib/views/todo_detail_read.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../models/tag.dart';

/// TodoDetailPage에서 읽기 전용 모드로 사용할 위젯.
/// [todo]와 날짜/시간 포맷 함수만 전달받으면 이 안에서 모든 UI를 그립니다.
class TodoDetailReadView extends StatelessWidget {
  final Todo todo;

  const TodoDetailReadView({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1) 이미지 표시
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: todo.imagePath == null
              ? Center(
                  child: Icon(
                    Icons.photo,
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
                ),
        ),
        const SizedBox(height: 24),

        // 2) 제목
        Text(
          todo.title,
          style:
              textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 16),

        // 3) 태그 목록 (읽기 전용)
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: todo.tags.map((Tag tag) {
            return Chip(
              label: Text(tag.name),
              backgroundColor: colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }
}
