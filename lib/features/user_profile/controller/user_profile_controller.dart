import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/apis/storage_api.dart';
import 'package:twitte_clone/apis/tweet_api.dart';
import 'package:twitte_clone/apis/user_api.dart';
import 'package:twitte_clone/core/enums/notification_type_enum.dart';
import 'package:twitte_clone/core/utils.dart';
import 'package:twitte_clone/features/notification/controller/notification_controller.dart';
import 'package:twitte_clone/models/tweet_model.dart';
import 'package:twitte_clone/models/user_model.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final tweetApi = ref.watch(tweetApiProvider);
  final storageApi = ref.watch(storageApiProvider);
  final userApi = ref.watch(userApiProvider);
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return UserProfileController(
      tweetApi: tweetApi,
      storageApi: storageApi,
      userApi: userApi,
      notificationController: notificationController);
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) {
  return ref.watch(userProfileControllerProvider.notifier).getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userApi = ref.watch(userApiProvider);
  return userApi.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetApi _tweetApi;
  final StorageApi _storageApi;
  final UserApi _userApi;
  final NotificationController _notificationController;
  UserProfileController({
    required TweetApi tweetApi,
    required StorageApi storageApi,
    required UserApi userApi,
    required NotificationController notificationController,
  })  : _tweetApi = tweetApi,
        _storageApi = storageApi,
        _userApi = userApi,
        _notificationController = notificationController,
        super(false);

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }
    user = user.copyWith(followers: user.followers);
    currentUser.copyWith(following: currentUser.following);

    final res1 = await _userApi.followUser(user);
    res1.fold((l) => showSnackBar(context, l.message), (r) async {
      final res2 = await _userApi.addToFollowingUser(currentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
            text: '${currentUser.name} followed on you!',
            postId: '',
            notificationType: NotificationType.follow,
            uid: user.uid);
      });
    });
  }

  Future<List<Tweet>> getUserTweets(String uid) async {
    final tweetList = await _tweetApi.getUserTweets(uid);
    final updatedTweetList =
        tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
    return updatedTweetList;
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    var bannerLink = "";
    var profileLink = "";
    if (bannerFile != null) {
      bannerLink = await _storageApi.uploadSingleImage(bannerFile);
      userModel = userModel.copyWith(bannerPic: bannerLink);
    }

    if (profileFile != null) {
      profileLink = await _storageApi.uploadSingleImage(profileFile);
      userModel = userModel.copyWith(profilePic: profileLink);
    }

    final res = await _userApi.updateUserData(userModel);
    state = false;
    res.fold(
      (l) {
        showSnackBar(context, l.message);
        state = false;
      },
      (r) => Navigator.pop(context),
    );
  }
}
