import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fpdart/fpdart.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/core/core.dart';
import 'package:twitte_clone/core/providers.dart';
import 'package:twitte_clone/models/notification_model.dart';

abstract class INotificationAPI {
  FutureEitherVoid createNotification(NotificationModel notification);
  Future<List<Document>> getNotifications(String uid);
  Stream<RealtimeMessage> getLatestNotification();
}

final notificationApiProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabaseProvider);
  final realtime = ref.watch(appwriteRealtimeProviderForNotification);
  return NotificationAPI(db: db, realtime: realtime);
});

class NotificationAPI implements INotificationAPI {
  final Databases _db;
  final Realtime _realtime;

  NotificationAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  Future<List<Document>> getNotifications(String uid) async {
    final tweetList = await _db.listDocuments(
      databaseId: AppWriteConstants.databaseId,
      collectionId: AppWriteConstants.notificationsCollections,
      queries: [Query.equal('uid', uid)],
    );
    return tweetList.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotification() {
    final subscription = _realtime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.notificationsCollections}.documents'
    ]).stream;

    return subscription;
  }

  @override
  FutureEitherVoid createNotification(NotificationModel notification) async {
    try {
      await _db.createDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.notificationsCollections,
        documentId: ID.unique(),
        data: notification.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'something went wrong while updating',
          st.toString(),
        ),
      );
    } catch (e, st) {
      return left(
        Failure(
          e.toString(),
          st.toString(),
        ),
      );
    }
  }
}
