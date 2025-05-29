import 'package:hive/hive.dart';
import 'package:todolist/models/user.dart';

class UserRepository {
  static const String _boxName = 'userBox';

  Future<void> saveUser(User user) async {
    final box = await Hive.openBox<User>(_boxName);
    await box.put('user', user);
  }

  Future<User?> loadUser() async {
    final box = await Hive.openBox<User>(_boxName);
    return box.get('user');
  }
}
