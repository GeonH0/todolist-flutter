// lib/views/todo_list_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todolist/models/tag.dart';
import '../viewmodels/todo_list_viewmodel.dart';
import '../models/todo.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final tagFilterProvider = StateProvider<Tag?>((ref) => null);

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final allTodos = ref.watch(todoListViewModelProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final tagFilter = ref.watch(tagFilterProvider);

  // 태그 필터링: selectedTag(enum)과 todo.tags(List<Tag>)를 직접 비교
  final afterTag = tagFilter == null
      ? allTodos
      : allTodos.where((todo) => todo.tags.contains(tagFilter)).toList();

  if (query.isEmpty) return afterTag;
  return afterTag
      .where((todo) => todo.title.toLowerCase().contains(query))
      .toList();
});

class TodoListTab extends ConsumerWidget {
  const TodoListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTodos = ref.watch(todoListViewModelProvider);
    final filteredTodos = ref.watch(filteredTodosProvider);
    final selectedTag = ref.watch(tagFilterProvider);
    final todoNotifier = ref.read(todoListViewModelProvider.notifier);

    // Theme 속성 가져오기
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 상태바 높이 확보
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // 상태바 영역을 primary 색으로 채우기
        Container(
          color: colorScheme.primary,
          height: topPadding,
        ),

        // “Today” 헤더
        Container(
          color: colorScheme.primary,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_monthName(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}',
                style: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // 나머지 콘텐츠
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 검색창 (InputDecorationTheme이 이미 적용됨)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    style: TextStyle(color: colorScheme.onBackground),
                    decoration: InputDecoration(
                      hintText: 'Search todos...',
                    ),
                    onChanged: (text) {
                      ref.read(searchQueryProvider.notifier).state = text;
                    },
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: selectedTag == null,
                        onSelected: (_) {
                          ref.read(tagFilterProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...{for (var todo in allTodos) ...todo.tags}
                          .toSet()
                          .map((tag) {
                        final tagName = tag.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tagName),
                            selected: selectedTag == tag,
                            onSelected: (_) {
                              final current = ref.read(tagFilterProvider);
                              ref.read(tagFilterProvider.notifier).state =
                                  (current == tag) ? null : tag;
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Todo 목록(ListView)
                Expanded(
                  child: filteredTodos.isEmpty
                      ? Center(
                          child: Text(
                            'No todos found.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTodos.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            final isCompleted = todo.isCompleted;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey(todo.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) async {
                                  await todoNotifier.deleteTodo(todo.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Deleted: ${todo.title}'),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await todoNotifier
                                              .toggleCompletion(todo.id);
                                        },
                                        child: Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isCompleted
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                  .withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          todo.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: colorScheme.onSurface,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.go('/todos/${todo.id}');
                                        },
                                        child: Text(
                                          _formatTime(todo.createdAt),
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month];
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'am' : 'pm';
    return '$hour:$minute $period';
  }
}
