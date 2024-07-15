import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/error_page.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitte_clone/models/tweet_model.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_card.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) => ref.watch(getLatestTweetProvider).when(
            data: (data) {
              if (data.events.contains(
                  'databases.*.collections.${AppWriteConstants.tweetCollections}.documents.*.create')) {
                tweets.insert(0, Tweet.fromMap(data.payload));
              } else if (data.events.contains(
                  'databases.*.collections.${AppWriteConstants.tweetCollections}.documents.*.update')) {
                var tweet = Tweet.fromMap(data.payload);

                final tweetId = tweet.id;

                tweet = tweets.where((element) => element.id == tweetId).first;

                final tweetIndex = tweets.indexOf(tweet);

                tweets.removeAt(tweetIndex);
                tweet = Tweet.fromMap(data.payload);
                tweets.insert(tweetIndex, tweet);
              }

              return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];

                    return TweetCard(tweet: tweet);
                  });
            },
            error: (error, st) {
              return ErrorText(
                error: error.toString(),
              );
            },
            loading: () {
              return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];

                    return TweetCard(tweet: tweet);
                  });
            },
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
