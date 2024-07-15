// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/explore/view/explore_view.dart';
import 'package:twitte_clone/features/notification/view/notification_view.dart';
import 'package:twitte_clone/features/tweet/widgets/tweet_list.dart';
import 'package:twitte_clone/theme/theme.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        width: 40,
        height: 40,
        colorFilter: const ColorFilter.mode(Pallete.blueColor, BlendMode.srcIn),
      ),
      centerTitle: true,
    );
  }

  static List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreView(),
    NotificationView()
  ];
}
