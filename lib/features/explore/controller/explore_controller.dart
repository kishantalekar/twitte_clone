import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/apis/user_api.dart';
import 'package:twitte_clone/models/user_model.dart';

final exploreControllerProvider =
    StateNotifierProvider<ExploreController, bool>((ref) {
  return ExploreController(userApi: ref.watch(userApiProvider));
});

final searchUserProvider = FutureProvider.family((ref, String name) async {
  return ref.watch(exploreControllerProvider.notifier).searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  ExploreController({required UserApi userApi})
      : _userApi = userApi,
        super(false);

  final UserApi _userApi;
  Future<List<UserModel>> searchUser(String name) async {
    final userList = await _userApi.getUsersBySearch(name);

    final updatedUserList =
        userList.map((user) => UserModel.fromMap(user.data)).toList();

    return updatedUserList;
  }
}
