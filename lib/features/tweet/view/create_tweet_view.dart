import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/core/utils.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitte_clone/theme/pallete.dart';

class CreateTweetScreen extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const CreateTweetScreen());

  const CreateTweetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTweetScreenState();
}

class _CreateTweetScreenState extends ConsumerState<CreateTweetScreen> {
  final tweetTextController = TextEditingController();
  List<File> images = [];

  @override
  void dispose() {
    super.dispose();
  }

  void onPickImages() async {
    images = await pickImages();
    setState(() {});
  }

  void shareTweet() {
    ref.watch(tweetControllerProvider.notifier).shareTweet(
        images: images,
        text: tweetTextController.text,
        context: context,
        repliedTo: '',
        repliedToUserId: '');

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailProvider).value;

    final isLoading = ref.watch(tweetControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          RoundedSmallButton(
              onTap: shareTweet,
              label: "Tweet",
              backgroundColor: Pallete.blueColor,
              textColor: Pallete.whiteColor)
        ],
      ),
      body: isLoading || currentUser == null
          ? const Loader()
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(currentUser.profilePic),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            controller: tweetTextController,
                            decoration: const InputDecoration(
                                hintText: "What's happening",
                                hintStyle: TextStyle(
                                    color: Pallete.greyColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600),
                                border: InputBorder.none),
                          ),
                        )
                      ],
                    ),
                    if (images.isNotEmpty)
                      CarouselSlider(
                        items: images.map((file) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.file(file));
                        }).toList(),
                        options: CarouselOptions(
                            enableInfiniteScroll: false, height: 400),
                      )
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Pallete.greyColor, width: 0.4),
          ),
        ),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 15, right: 15),
            child: GestureDetector(
                onTap: onPickImages,
                child: SvgPicture.asset(AssetsConstants.galleryIcon)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 15, right: 15),
            child: SvgPicture.asset(AssetsConstants.gifIcon),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 15, right: 15),
            child: SvgPicture.asset(AssetsConstants.emojiIcon),
          ),
        ]),
      ),
    );
  }
}
