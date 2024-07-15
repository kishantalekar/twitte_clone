import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/apis/notification_api.dart';
import 'package:twitte_clone/core/enums/notification_type_enum.dart';
import 'package:twitte_clone/models/notification_model.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationApi = ref.watch(notificationApiProvider);

  return NotificationController(notificationAPI: notificationApi);
});

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationApi = ref.watch(notificationApiProvider);
  return notificationApi.getLatestNotification();
});

final getNotificationsProvider = FutureProvider.family((ref, String uid) async {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return notificationController.getNotifications(uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;
  NotificationController({required NotificationAPI notificationAPI})
      : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required NotificationType notificationType,
    required String uid,
  }) async {
    final notification = NotificationModel(
        text: text,
        postId: postId,
        id: '',
        uid: uid,
        notificationType: notificationType);
    final res = await _notificationAPI.createNotification(notification);
    res.fold((l) => null, (r) => null);
  }

  Future<List<NotificationModel>> getNotifications(String uid) async {
    final notifications = await _notificationAPI.getNotifications(uid);
    final updatedNotifications =
        notifications.map((e) => NotificationModel.fromMap(e.data)).toList();
    return updatedNotifications;
  }
}
