import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fpdart/fpdart.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/core/core.dart';
import 'package:twitte_clone/core/providers.dart';
import 'package:twitte_clone/models/user_model.dart';

final userApiProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabaseProvider);
  final realTime = ref.watch(appwriteRealtimeProviderForProfile);
  return UserApi(db: db, realtime: realTime);
});

abstract class IUserApi {
  FutureEitherVoid saveUserData(UserModel userModel);
  Future<Document> getUserData(String uid);
  Future<List<Document>> getUsersBySearch(String name);
  FutureEitherVoid updateUserData(UserModel user);
  Stream<RealtimeMessage> getLatestUserProfileData();
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowingUser(UserModel user);
}

class UserApi implements IUserApi {
  final Databases _db;
  final Realtime _realtime;

  UserApi({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  Stream<RealtimeMessage> getLatestUserProfileData() {
    return _realtime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.usersCollections}.documents'
    ]).stream;
  }

  @override
  Future<Document> getUserData(String uid) {
    return _db.getDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.usersCollections,
        documentId: uid);
  }

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      await _db.createDocument(
          databaseId: AppWriteConstants.databaseId,
          collectionId: AppWriteConstants.usersCollections,
          documentId: userModel.uid,
          data: userModel.toMap());
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? "unexpected error occured",
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

  @override
  Future<List<Document>> getUsersBySearch(String name) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.usersCollections,
        queries: [Query.search('name', name)]);

    return documents.documents;
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _db.updateDocument(
          databaseId: AppWriteConstants.databaseId,
          collectionId: AppWriteConstants.usersCollections,
          documentId: userModel.uid,
          data: userModel.toMap());
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

  @override
  FutureEitherVoid followUser(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.usersCollections,
        documentId: user.uid,
        data: {'followers': user.followers},
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

  @override
  FutureEitherVoid addToFollowingUser(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.usersCollections,
        documentId: user.uid,
        data: {
          'following': user.following,
        },
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
