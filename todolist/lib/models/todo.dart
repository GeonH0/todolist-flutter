// lib/models/todo.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? imagePath;

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final bool isCompleted;

  Todo({
    String? id,
    required this.title,
    this.imagePath,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Todo._internal({
    required this.id,
    required this.title,
    this.imagePath,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });

  Todo copyWith(
      {String? title,
      String? imagePath,
      List<String>? tags,
      DateTime? updatedAt,
      bool? isCompleted}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
