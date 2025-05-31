// lib/models/tag.dart

import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 2) // 기존 1에서 2로 변경
enum Tag {
  @HiveField(0)
  work,

  @HiveField(1)
  personal,

  @HiveField(2)
  study,

  @HiveField(3)
  shopping,
}
