import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/constants/assets_constants.dart';
import 'package:twitte_clone/core/enums/tweet_type_enum.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitte_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitte_clone/models/tweet_model.dart';
import 'package:twitte_clone/features/tweet/view/tweet_reply_view.dart';
import 'package:twitte_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitte_clone/features/tweet/widgets/hashtag_text.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_icon_button.dart';

import 'package:twitte_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  const TweetCard({super.key, required this.tweet});

  final Tweet tweet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<bool?> handleLike() async {
      final currentUser = ref.watch(currentUserDetailProvider).value;

      if (currentUser == null) return null;
      ref
          .watch(tweetControllerProvider.notifier)
          .likeTweet(tweet, currentUser, context);
      return true;
    }

    void handleRetweet() {
      final currentUser = ref.watch(currentUserDetailProvider).value!;
      ref
          .watch(tweetControllerProvider.notifier)
          .reshareTweet(tweet, currentUser, context);
    }

    final currentUser = ref.watch(currentUserDetailProvider).value;
    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweet.uid)).when(
            data: (user) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      TweetReplyView.route(tweet),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context, UserProfileView.route(user)),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 25,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tweet.retweetedBy.isNotEmpty)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsConstants.retweetIcon,
                                        colorFilter: const ColorFilter.mode(
                                          Pallete.greyColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: 14,
                                        height: 14,
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "${tweet.retweetedBy} retweeted",
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          right: user.isTwitterBlue ? 0 : 5),
                                      child: Text(
                                        user.name.length > 14
                                            ? user.name.substring(0, 15)
                                            : user.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    if (user.isTwitterBlue)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: SvgPicture.asset(
                                          AssetsConstants.verifiedIcon,
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context, UserProfileView.route(user)),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        '@${user.name} · ${timeago.format(tweet.tweetedAt, locale: 'en_short')}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Pallete.greyColor),
                                      ),
                                    ),
                                  ],
                                ),
                                if (tweet.repliedTo.isNotEmpty)
                                  ref
                                      .watch(
                                          getTweetByIdProvider(tweet.repliedTo))
                                      .when(
                                        data: (repliedToTweet) {
                                          final repliedToUser = ref
                                              .watch(userDetailsProvider(
                                                  repliedToTweet.uid))
                                              .value;
                                          return RichText(
                                            text: TextSpan(
                                                text: "Replied to ",
                                                style: const TextStyle(
                                                    color: Pallete.greyColor),
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          "@${repliedToUser?.name}",
                                                      style: const TextStyle(
                                                          color: Pallete
                                                              .blueColor)),
                                                ]),
                                          );
                                        },
                                        error: (err, st) {
                                          return Text(err.toString());
                                        },
                                        loading: () => const SizedBox(),
                                      ),
                                HashTagText(text: tweet.text),
                                if (tweet.tweetType == TweetType.image)
                                  CarouselImage(imageLinks: tweet.imageLinks),
                                if (tweet.link.isNotEmpty) ...[
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  AnyLinkPreview(
                                    link: tweet.link,
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                  ),
                                ],
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TweetIconButton(
                                          pathname: AssetsConstants.viewsIcon,
                                          text: (tweet.commentIds.length +
                                                  tweet.reshareCount +
                                                  tweet.likes.length)
                                              .toString(),
                                          onTap: () {}),
                                      TweetIconButton(
                                          pathname: AssetsConstants.commentIcon,
                                          text: (tweet.commentIds.length)
                                              .toString(),
                                          onTap: () {
                                            Navigator.push(context,
                                                TweetReplyView.route(tweet));
                                          }),
                                      TweetIconButton(
                                          pathname: AssetsConstants.retweetIcon,
                                          text: (tweet.reshareCount).toString(),
                                          onTap: handleRetweet),
                                      LikeButton(
                                        isLiked: tweet.likes
                                            .contains(currentUser.uid),
                                        onTap: (isliked) async {
                                          bool? result = await handleLike();
                                          return result;
                                          // Handle the result if needed
                                        },
                                        size: 25,
                                        likeCount: tweet.likes.length,
                                        countBuilder:
                                            (likeCount, isLiked, text) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: isLiked
                                                      ? Pallete.redColor
                                                      : Pallete.greyColor),
                                            ),
                                          );
                                        },
                                        likeBuilder: (isLiked) {
                                          return isLiked
                                              ? SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeFilledIcon,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          Pallete.redColor,
                                                          BlendMode.srcIn),
                                                )
                                              : SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeOutlinedIcon,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          Pallete.greyColor,
                                                          BlendMode.srcIn),
                                                );
                                        },
                                      ),
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.share,
                                            size: 25,
                                            color: Pallete.greyColor,
                                          ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Pallete.greyColor,
                      )
                    ],
                  ),
                ),
            error: (err, st) => ErrorText(error: err.toString()),
            loading: () => const Loader());
  }
}
