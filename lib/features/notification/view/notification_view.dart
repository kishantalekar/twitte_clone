import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/common.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/notification/controller/notification_controller.dart';
import 'package:twitte_clone/features/notification/widget/notification_tile.dart';
import 'package:twitte_clone/models/notification_model.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  static route() =>
      MaterialPageRoute(builder: (context) => const NotificationView());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailProvider).value;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Notifications"),
        ),
        body: currentUser == null
            ? const Loader()
            : ref.watch(getNotificationsProvider(currentUser.uid)).when(
                  data: (notifications) =>
                      ref.watch(getLatestNotificationProvider).when(
                    data: (data) {
                      if (data.events.contains(
                        'databases.*.collections.${AppWriteConstants.notificationsCollections}.documents.*.create',
                      )) {
                        final latestNotif =
                            NotificationModel.fromMap(data.payload);
                        if (latestNotif.uid == currentUser.uid) {
                          notifications.insert(0, latestNotif);
                        }
                      }

                      return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];

                            return NotificationTile(notification: notification);
                          });
                    },
                    error: (error, st) {
                      return ErrorText(
                        error: error.toString(),
                      );
                    },
                    loading: () {
                      return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];

                            return NotificationTile(notification: notification);
                          });
                    },
                  ),
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ));
  }
}
