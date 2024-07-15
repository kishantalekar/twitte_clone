import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/apis/storage_api.dart';
import 'package:twitte_clone/apis/tweet_api.dart';
import 'package:twitte_clone/core/enums/notification_type_enum.dart';
import 'package:twitte_clone/core/enums/tweet_type_enum.dart';
import 'package:twitte_clone/core/utils.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/notification/controller/notification_controller.dart';
import 'package:twitte_clone/models/tweet_model.dart';
import 'package:twitte_clone/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider.autoDispose<TweetController, bool>((ref) {
  final tweetApi = ref.watch(tweetApiProvider);

  final storageApi = ref.watch(storageApiProvider);
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return TweetController(
    ref: ref,
    tweetApi: tweetApi,
    storageApi: storageApi,
    notificationController: notificationController,
  );
});
final getTweetsProvider = FutureProvider.autoDispose((ref) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweets();
});
final getTweetsRepliesProvider =
    FutureProvider.family.autoDispose((ref, Tweet tweet) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweetReplies(tweet);
});

final getLatestTweetProvider = StreamProvider.autoDispose((ref) {
  final tweetApi = ref.watch(tweetApiProvider);
  return tweetApi.getLatestTweet();
});

final getTweetByIdProvider =
    FutureProvider.autoDispose.family((ref, String id) async {
  final tweet = ref.watch(tweetControllerProvider.notifier).getTweetById(id);
  return tweet;
});
final getTweetByHashtagProvider =
    FutureProvider.autoDispose.family((ref, String hashtag) async {
  final tweets =
      ref.watch(tweetControllerProvider.notifier).getTweetByHashtag(hashtag);
  return tweets;
});

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetApi _tweetApi;
  final StorageApi _storageApi;
  final NotificationController _notificationController;
  TweetController(
      {required Ref ref,
      required TweetApi tweetApi,
      required StorageApi storageApi,
      required NotificationController notificationController})
      : _ref = ref,
        _tweetApi = tweetApi,
        _storageApi = storageApi,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getTweetByHashtag(String hashtag) async {
    final tweets = await _tweetApi.getTweetsByHastag(hashtag);

    final updatedTweets =
        tweets.map((tweet) => Tweet.fromMap(tweet.data)).toList();
    return updatedTweets;
  }

  Future<Tweet> getTweetById(String id) async {
    final res = await _tweetApi.getTweetById(id);
    final tweet = Tweet.fromMap(res.data);
    return tweet;
  }

  Future<List<Tweet>> getTweetReplies(Tweet tweet) async {
    final tweetList = await _tweetApi.getRepliesToTweet(tweet);

    final updatedTweetList =
        tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
    return updatedTweetList;
  }

  void likeTweet(Tweet tweet, UserModel user, BuildContext context) async {
    List<String> likes = tweet.likes;

    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }
    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetApi.likeTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _notificationController.createNotification(
          text: '${user.name} liked  your tweet!',
          postId: tweet.id,
          notificationType: NotificationType.like,
          uid: tweet.uid);
    });
  }

  void reshareTweet(
      Tweet tweet, UserModel currentUser, BuildContext context) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      reshareCount: tweet.reshareCount + 1,
      likes: [],
      commentIds: [],
    );
    final res = await _tweetApi.updateReshareCount(tweet);

    res.fold((l) => showSnackBar(context, l.message), (r) async {
      tweet = tweet.copyWith(
        id: ID.unique(),
        reshareCount: 0,
        tweetedAt: DateTime.now(),
      );
      final res2 = await _tweetApi.shareTweet(tweet);
      res2.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          _notificationController.createNotification(
              text: '${currentUser.name} reshared your tweet!',
              postId: tweet.id,
              notificationType: NotificationType.retweet,
              uid: tweet.uid);
          showSnackBar(context, "Retweet successfully");
        },
      );
    });
  }

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetApi.getTweets();
    final updatedTweetList =
        tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
    return updatedTweetList;
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, "Please enter text");
      return;
    }
    if (images.isNotEmpty) {
      _shareImageTweet(
          images: images,
          text: text,
          context: context,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    } else {
      _shareTextTweet(
        repliedToUserId: repliedToUserId,
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    }
  }

  void _shareImageTweet(
      {required List<File> images,
      required String text,
      required BuildContext context,
      required String repliedTo,
      required String repliedToUserId}) async {
    state = true;

    final hashtags = _getHashTagsFromText(text);
    String link = _getLinkFromText(text);

    final user = _ref.read(currentUserDetailProvider).value!;

    final imageLinks = await _storageApi.uploadImage(images);

    Tweet tweet = Tweet(
        text: text,
        hashtags: hashtags,
        link: link,
        imageLinks: imageLinks,
        uid: user.uid,
        tweetType: TweetType.image,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        id: '',
        reshareCount: 0,
        retweetedBy: '',
        repliedTo: repliedTo);

    final res = await _tweetApi.shareTweet(tweet);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) async {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
            text: '${user.name} replied on your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId);
      }
      showSnackBar(context, 'tweeted successfully');
    });
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;

    final hashtags = _getHashTagsFromText(text);
    String link = _getLinkFromText(text);

    final user = _ref.read(currentUserDetailProvider).value!;

    Tweet tweet = Tweet(
        text: text,
        hashtags: hashtags,
        link: link,
        imageLinks: const [],
        uid: user.uid,
        tweetType: TweetType.text,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        id: '',
        reshareCount: 0,
        retweetedBy: '',
        repliedTo: repliedTo);

    final res = await _tweetApi.shareTweet(tweet);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
            text: '${user.name} replied on your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId);
      }
      showSnackBar(context, 'tweeted successfully');
    });
  }

  String _getLinkFromText(String text) {
    List<String> wordsInSentence = text.split(' ');

    String link = '';

    for (String word in wordsInSentence) {
      if (_isValidUrl(word)) {
        link = word;
        break; // Stop searching after finding the first valid URL
      }
    }
    return link;
  }

  bool _isValidUrl(String url) {
    Uri uri =
        Uri.tryParse(url) ?? Uri(); // Use Uri.tryParse to check for a valid URL
    return uri.isAbsolute;
  }

  List<String> _getHashTagsFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    List<String> hashTags = [];
    for (String word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashTags.add(word);
      }
    }
    return hashTags;
  }
}
