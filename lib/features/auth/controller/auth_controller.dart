import 'package:appwrite/models.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/apis/auth_api.dart';
import 'package:twitte_clone/apis/user_api.dart';
import 'package:twitte_clone/core/utils.dart';
import 'package:twitte_clone/features/auth/view/login_view.dart';
import 'package:twitte_clone/features/auth/view/signup_view.dart';
import 'package:twitte_clone/features/home/view/home_view.dart';
import 'package:twitte_clone/models/user_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  final authApi = ref.watch(authProvider);
  final userApi = ref.watch(userApiProvider);
  return AuthController(authApi: authApi, userApi: userApi);
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

final currentUserDetailProvider = FutureProvider((ref) {
  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(userDetailsProvider(currentUserId));
  return userDetails.value;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final userDetails =
      ref.watch(authControllerProvider.notifier).getUserData(uid);
  return userDetails;
});

class AuthController extends StateNotifier<bool> {
  final AuthApi _authApi;
  final UserApi _userApi;
  AuthController({required AuthApi authApi, required UserApi userApi})
      : _authApi = authApi,
        _userApi = userApi,
        super(false);

  Future<model.User?> currentUser() => _authApi.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _authApi.signUp(email: email, password: password);

    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        UserModel userModel = UserModel(
            email: email,
            name: getNameFromUser(email),
            followers: const [],
            following: const [],
            profilePic: '',
            bannerPic: '',
            bio: '',
            uid: r.$id,
            isTwitterBlue: false);
        final res = await _userApi.saveUserData(userModel);
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, "Account Created! please login.");
          Navigator.push(
            context,
            LoginView.route(),
          );
        });
      },
    );
  }

  void login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    state = true;

    final res = await _authApi.login(email: email, password: password);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Navigator.push(context, HomeView.route());
    });
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userApi.getUserData(uid);

    final updatedUser = UserModel.fromMap(document.data);

    return updatedUser;
  }

  void logout(BuildContext context) async {
    final res = await _authApi.logout();

    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => Navigator.of(context)
            .pushAndRemoveUntil(SignUpView.route(), (route) => false));
  }
}
