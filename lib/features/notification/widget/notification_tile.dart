// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitte_clone/constants/assets_constants.dart';
import 'package:twitte_clone/core/enums/notification_type_enum.dart';
import 'package:twitte_clone/models/notification_model.dart';
import 'package:twitte_clone/theme/pallete.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notification.notificationType == NotificationType.follow
          ? const Icon(
              Icons.person,
              color: Pallete.blueColor,
            )
          : notification.notificationType == NotificationType.like
              ? SvgPicture.asset(AssetsConstants.likeFilledIcon,
                  color: Pallete.redColor, height: 20)
              : notification.notificationType == NotificationType.retweet
                  ? SvgPicture.asset(
                      AssetsConstants.retweetIcon,
                      color: Pallete.whiteColor,
                      height: 20,
                    )
                  : null,
      title: Text(notification.text),
    );
  }
}
