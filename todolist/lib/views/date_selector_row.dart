import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/date_time_utils.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final pressedIndexProvider = StateProvider<int>((ref) => -1);

const int _itemCount = 100;
final int _centerIndex = _itemCount ~/ 2;

/// 날짜 선택 바: 5개가 항상 보이고, 중앙이 선택된 날짜가 되도록
class DateSelectorRow extends ConsumerStatefulWidget {
  const DateSelectorRow({super.key});

  @override
  ConsumerState<DateSelectorRow> createState() => _DateSelectorRowState();
}

class _DateSelectorRowState extends ConsumerState<DateSelectorRow> {
  late final PageController _pageController;
  int pressedIndex = -1; // InkWell 누른 인덱스 저장

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _centerIndex,
      viewportFraction: 0.2,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final centerDate = indexToDate(_centerIndex);
      ref.read(selectedDateProvider.notifier).state = centerDate;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime indexToDate(int index) {
    final today = DateTime.now();
    final offsetDays = index - _centerIndex;
    return DateTime(today.year, today.month, today.day)
        .add(Duration(days: offsetDays));
  }

  int dateToIndex(DateTime date) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final diff = date.difference(base).inDays;
    return _centerIndex + diff;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final rowHeight = screenHeight * 0.10;

    return SizedBox(
      height: rowHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _itemCount,
        onPageChanged: (idx) {
          final d = indexToDate(idx);
          ref.read(selectedDateProvider.notifier).state = d;
        },
        itemBuilder: (context, idx) {
          final date = indexToDate(idx);
          final monthShort = monthShortName(date.month);
          final dayNum = date.day.toString().padLeft(2, '0');
          final weekday = weekdayShortName(date.weekday);

          final isSelected = selectedDate.year == date.year &&
              selectedDate.month == date.month &&
              selectedDate.day == date.day;

          final isPressed = pressedIndex == idx;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.7),
            decoration: BoxDecoration(
              color:
                  isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (isSelected || isPressed)
                  BoxShadow(
                    color: colorScheme.primary
                        .withOpacity(isPressed ? 0.45 : 0.30),
                    blurRadius: isPressed ? 18 : 12,
                    offset: const Offset(0, 6),
                  )
              ],
              border: Border.all(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onHighlightChanged: (highlighted) {
                ref.read(pressedIndexProvider.notifier).state =
                    highlighted ? idx : -1;
              },
              onTap: () {
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                ref.read(selectedDateProvider.notifier).state = date;
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthShort,
                      style: TextStyle(
                        fontSize: rowHeight * 0.15,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: rowHeight * 0.09),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: rowHeight * 0.28,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: rowHeight * 0.04),
                    Text(
                      weekday,
                      style: TextStyle(
                        fontSize: rowHeight * 0.13,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
