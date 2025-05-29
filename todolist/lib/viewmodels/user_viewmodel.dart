import 'package:riverpod/riverpod.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, User?>((ref) {
  return UserViewModel(UserRepository());
});

class UserViewModel extends StateNotifier<User?> {
  final UserRepository _repository;

  UserViewModel(this._repository) : super(null) {
    _initUser();
  }

  Future<void> _initUser() async {
    User? user = await _repository.loadUser();
    if (user == null) {
      user = User(name: '이름 없음', photoPath: null);
      await _repository.saveUser(user);
    }
    state = user;
  }

  Future<void> updateUser({String? name, String? photoPath}) async {
    if (state == null) return;
    final updatedUser = state!.copyWith(name: name, photoPath: photoPath);
    await _repository.saveUser(updatedUser);
    state = updatedUser;
  }
}
