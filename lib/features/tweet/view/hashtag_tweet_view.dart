import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_card.dart';

class HashtagView extends ConsumerWidget {
  static route(String hashtag) => MaterialPageRoute(
        builder: (context) => HashtagView(
          hashtag: hashtag,
        ),
      );

  final String hashtag;
  const HashtagView({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(hashtag)),
      body: ref.watch(getTweetByHashtagProvider(hashtag)).when(
          data: (tweets) {
            return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  final tweet = tweets[index];
                  return TweetCard(tweet: tweet);
                });
          },
          error: (err, st) => ErrorText(error: err.toString()),
          loading: () => const Loader()),
    );
  }
}
