// lib/views/todo_list_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:todolist/models/tag.dart';
import 'package:todolist/views/date_selector_row.dart';

import '../models/todo.dart';
import '../viewmodels/todo_list_viewmodel.dart';
import '../utils/date_time_utils.dart';

/// 검색어를 저장하는 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 태그별 필터를 저장하는 Provider (null이면 전체)
final tagFilterProvider = StateProvider<Tag?>((ref) => null);

/// 전체 Todo + 검색어 + 태그 + 선택된 날짜를 반영해서 최종 리스트 계산
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final allTodos = ref.watch(todoListViewModelProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final tagFilter = ref.watch(tagFilterProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  final filteredByDate = allTodos.where((todo) {
    // 1) createdAt의 연·월·일만 남겨서 비교
    final created = DateTime(
      todo.createdAt.year,
      todo.createdAt.month,
      todo.createdAt.day,
    );

    // 생성일이 선택된 날짜 이후면(예: 6/1 생성된 Todo인데 5/30 선택) 무조건 제외
    if (created.isAfter(selectedDate)) {
      return false;
    }

    final due = todo.dueDate;
    if (due != null) {
      // dueDate가 있으면 “dueDate ≥ selectedDate”인 경우만 허용
      return !due.isBefore(selectedDate);
    } else {
      // dueDate가 없으면, 생성일 == selectedDate인 경우에만 허용
      return created == selectedDate;
    }
  }).toList();

  // 1) 태그 필터링
  final afterTag = tagFilter == null
      ? filteredByDate
      : filteredByDate.where((todo) => todo.tags.contains(tagFilter)).toList();

  // 2) 검색어 필터링
  if (query.isEmpty) return afterTag;
  return afterTag
      .where((todo) => todo.title.toLowerCase().contains(query))
      .toList();
});

class TodoListTab extends ConsumerWidget {
  const TodoListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) 전체 Todo 구독
    final allTodos = ref.watch(todoListViewModelProvider);
    // 2) 날짜+태그+검색어 필터가 반영된 최종 리스트
    final filtered = ref.watch(filteredTodosProvider);
    final selectedTag = ref.watch(tagFilterProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final notifier = ref.read(todoListViewModelProvider.notifier);

    // MediaQuery 정보
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // [A] 카드 높이를 화면 높이의 약 0.12배로 설정
    final cardHeight = screenHeight * 0.12;
    // [B] 카드 내부 가로/세로 패딩을 비율로 설정
    final horizontalPadding = screenWidth * 0.03;
    final verticalPadding = cardHeight * 0.10;
    // [C] 폰트 크기를 화면 높이의 일정 배수로 조정
    final titleFontSize = screenHeight * 0.020;
    final timeFontSize = screenHeight * 0.014;
    final dueFontSize = screenHeight * 0.014;

    return Scaffold(
      // ShellRoute 쪽에서 이미 Scaffold + FAB + BottomNavigationBar를 처리하므로,
      // 여기서는 body 부분만 정의합니다.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ─── 상단 Status Bar 영역 + DateSelectorRow ───
            SafeArea(
              top: true,
              bottom: false,
              child: const DateSelectorRow(),
            ),

            const SizedBox(height: 8),

            // ─── “Selected Date” 표시 ───
            Container(
              color: colorScheme.primary,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    '${monthName(selectedDate.month)} '
                    '${selectedDate.day}, ${selectedDate.year}',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ─── 검색창 ───
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding * 0.5,
              ),
              child: TextField(
                style: TextStyle(color: colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: 'Search todos...',
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (text) {
                  ref.read(searchQueryProvider.notifier).state = text;
                },
              ),
            ),

            // ─── 태그 필터 ChoiceChip ───
            SizedBox(
              height: screenHeight * 0.05,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tag.name),
                        selected: selectedTag == tag,
                        onSelected: (_) {
                          ref.read(tagFilterProvider.notifier).state =
                              (selectedTag == tag) ? null : tag;
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Todo 목록(ListView) ───
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No todos due on or after '
                        '${monthShortName(selectedDate.month)} '
                        '${selectedDate.day}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final todo = filtered[index];
                        final isCompleted = todo.isCompleted;
                        final dueDate = todo.dueDate; // DateTime? 타입

                        return Padding(
                          padding: EdgeInsets.only(bottom: cardHeight * 0.1),
                          child: Dismissible(
                            key: ValueKey(todo.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await notifier.deleteTodo(todo.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted: ${todo.title}'),
                                ),
                              );
                            },
                            child: Card(
                              color: colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                height: cardHeight,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: verticalPadding,
                                ),
                                child: Row(
                                  children: [
                                    // 1) 완료 토글 아이콘
                                    GestureDetector(
                                      onTap: () async {
                                        await notifier
                                            .toggleCompletion(todo.id);
                                      },
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: cardHeight * 0.4,
                                        color: isCompleted
                                            ? colorScheme.primary
                                            : colorScheme.onSurface
                                                .withOpacity(0.6),
                                      ),
                                    ),

                                    SizedBox(width: horizontalPadding),

                                    // 2) 제목 + 시간(+마감일) 전체를 InkWell로 감싸서 상세 페이지 이동
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          context.go('/todos/${todo.id}');
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // 제목
                                            Text(
                                              todo.title,
                                              style: TextStyle(
                                                fontSize: titleFontSize,
                                                color: colorScheme.onSurface,
                                                decoration: isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                            ),

                                            // 생성 시각(시간)
                                            SizedBox(height: cardHeight * 0.06),
                                            Text(
                                              formatTime(todo.createdAt),
                                              style: TextStyle(
                                                fontSize: timeFontSize,
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                            ),

                                            // 마감일(dueDate)이 있으면 줄 바꿈하여 “Due: …” 표시
                                            if (dueDate != null) ...[
                                              SizedBox(
                                                  height: cardHeight * 0.04),
                                              Text(
                                                'Due: '
                                                '${monthShortName(dueDate.month)} '
                                                '${dueDate.day}, '
                                                '${dueDate.year} '
                                                '(${weekdayShortName(dueDate.weekday)})',
                                                style: TextStyle(
                                                  fontSize: dueFontSize,
                                                  fontStyle: FontStyle.italic,
                                                  color: colorScheme.error,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
