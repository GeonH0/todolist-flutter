import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? photoPath;

  User({required this.name, this.photoPath});

  User copyWith({
    String? name,
    String? photoPath,
  }) {
    return User(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
