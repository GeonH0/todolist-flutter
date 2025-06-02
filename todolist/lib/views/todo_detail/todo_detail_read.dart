// lib/views/todo_detail/todo_detail_read_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todolist/utils/date_time_utils.dart';
import '../../models/todo.dart';
import '../../models/tag.dart';

/// TodoDetailReadView: 읽기 전용 모드용 위젯
/// - [todo]: 표시할 Todo 객체
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

    // 1) 마감일 표시 문자열 계산
    String dueDateText() {
      final d = todo.dueDate;
      if (d == null) {
        return '마감일 없음';
      } else {
        final y = d.year;
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        final wd = weekdayShortName(d.weekday);
        return '$y-$m-$day ($wd)';
      }
    }

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
        const SizedBox(height: 16),

        // 4) 마감일 읽기 전용 표시
        Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Due Date: ${dueDateText()}',
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}
