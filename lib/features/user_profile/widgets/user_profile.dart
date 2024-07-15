import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/constants/assets_constants.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitte_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitte_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitte_clone/features/user_profile/widgets/follow_count.dart';
import 'package:twitte_clone/models/user_model.dart';
import 'package:twitte_clone/theme/pallete.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(
                                color: Pallete.blueColor,
                              )
                            : Image.network(user.bannerPic),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user.profilePic,
                          ),
                          radius: 35,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20),
                        alignment: Alignment.bottomRight,
                        child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Pallete.whiteColor,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25)),
                          onPressed: () {
                            if (currentUser.uid == user.uid) {
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .followUser(
                                      user: user,
                                      context: context,
                                      currentUser: currentUser);
                            }
                          },
                          child: Text(
                            currentUser.uid == user.uid
                                ? "Edit proifle"
                                : user.followers.contains(currentUser.uid)
                                    ? "following"
                                    : 'follow',
                            style: const TextStyle(color: Pallete.whiteColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isTwitterBlue)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 5.0, left: 5),
                                child: SvgPicture.asset(
                                  AssetsConstants.verifiedIcon,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          "@${user.name}",
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Pallete.greyColor),
                        ),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            FollowCount(
                                count: user.followers.length,
                                text: 'Followers'),
                            const SizedBox(
                              width: 10,
                            ),
                            FollowCount(
                                count: user.following.length,
                                text: 'Following'),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Divider(
                          color: Pallete.greyColor,
                        )
                      ],
                    ),
                  ),
                )
              ];
            },
            body: ref.watch(getUserTweetsProvider(user.uid)).when(
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
