import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitte_clone/models/tweet_model.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_card.dart';

class TweetReplyView extends ConsumerWidget {
  final Tweet tweet;
  const TweetReplyView({super.key, required this.tweet});

  static route(Tweet tweet) => MaterialPageRoute(
        builder: (context) => TweetReplyView(
          tweet: tweet,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Tweet')),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getTweetsRepliesProvider(tweet)).when(
                data: (tweets) => ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    final latestTweet = Tweet.fromMap(data.payload);

                    bool isTweetAlreadyPresent = false;
                    for (final tweetModel in tweets) {
                      if (tweetModel.id == latestTweet.id) {
                        isTweetAlreadyPresent = true;
                        break;
                      }
                    }
                    if (latestTweet.repliedTo == tweet.id &&
                        !isTweetAlreadyPresent) {
                      if (data.events.contains(
                          'databases.*.collections.${AppWriteConstants.tweetCollections}.documents.*.create')) {
                        tweets.insert(0, Tweet.fromMap(data.payload));
                      } else if (data.events.contains(
                          'databases.*.collections.${AppWriteConstants.tweetCollections}.documents.*.update')) {
                        var tweet = Tweet.fromMap(data.payload);

                        final tweetId = tweet.id;

                        tweet = tweets
                            .where((element) => element.id == tweetId)
                            .first;

                        final tweetIndex = tweets.indexOf(tweet);

                        tweets.removeAt(tweetIndex);
                        tweet = Tweet.fromMap(data.payload);
                        tweets.insert(tweetIndex, tweet);
                      }
                    }

                    return Expanded(
                      child: ListView.builder(
                          itemCount: tweets.length,
                          itemBuilder: (context, index) {
                            final tweet = tweets[index];

                            return TweetCard(tweet: tweet);
                          }),
                    );
                  },
                  error: (error, st) {
                    return ErrorText(
                      error: error.toString(),
                    );
                  },
                  loading: () {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: tweets.length,
                          itemBuilder: (context, index) {
                            final tweet = tweets[index];

                            return TweetCard(tweet: tweet);
                          }),
                    );
                  },
                ),
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onSubmitted: (value) {
            ref.watch(tweetControllerProvider.notifier).shareTweet(
                images: [],
                text: value,
                context: context,
                repliedTo: tweet.id,
                repliedToUserId: tweet.uid);
          },
          decoration: const InputDecoration(hintText: "Tweet your reply"),
        ),
      ),
    );
  }
}
