import 'package:hive/hive.dart';
import 'tag.dart';

part 'todo_draft.g.dart';

@HiveType(typeId: 3)
class TodoDraft {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? imagePath;

  @HiveField(2)
  List<Tag> tags;

  @HiveField(3)
  DateTime? dueDate;

  TodoDraft({
    this.title = '',
    this.imagePath,
    this.tags = const [],
    this.dueDate, // 기본값은 null
  });
}
