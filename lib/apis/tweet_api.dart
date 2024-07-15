import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitte_clone/constants/appwrite_constants.dart';
import 'package:twitte_clone/core/core.dart';
import 'package:twitte_clone/core/providers.dart';
import 'package:twitte_clone/models/tweet_model.dart';

final tweetApiProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabaseProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  return TweetApi(db: db, realTime: realtime);
});

abstract class ITweetApi {
  FutureEither<Document> shareTweet(Tweet tweet);
  Future<List<Document>> getTweets();
  Stream<RealtimeMessage> getLatestTweet();
  FutureEither<Document> likeTweet(Tweet tweet);
  FutureEither<Document> updateReshareCount(Tweet tweet);
  Future<List<Document>> getRepliesToTweet(Tweet tweet);
  Future<Document> getTweetById(String id);
  Future<List<Document>> getUserTweets(String uid);
  Future<List<Document>> getTweetsByHastag(String hashtag);
}

class TweetApi implements ITweetApi {
  final Databases _db;
  final Realtime _realtime;
  TweetApi({required Databases db, required Realtime realTime})
      : _db = db,
        _realtime = realTime;
  @override
  FutureEither<Document> shareTweet(Tweet tweet) async {
    try {
      final tweetDoc = await _db.createDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        documentId: ID.unique(),
        data: tweet.toMap(),
      );
      return right(tweetDoc);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? "something went wrong while sharing tweet",
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
  Future<List<Document>> getTweets() async {
    final tweetList = await _db.listDocuments(
      databaseId: AppWriteConstants.databaseId,
      collectionId: AppWriteConstants.tweetCollections,
      queries: [
        Query.orderDesc('tweetedAt'),
      ],
    );
    return tweetList.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestTweet() {
    final subscription = _realtime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.tweetCollections}.documents'
    ]).stream;

    return subscription;
  }

  @override
  FutureEither<Document> likeTweet(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        documentId: tweet.id,
        data: {
          'likes': tweet.likes,
        },
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? "something went wrong while liking",
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
  FutureEither<Document> updateReshareCount(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        documentId: tweet.id,
        data: {
          'reshareCount': tweet.reshareCount,
        },
      );
      return right(document);
    } on AppwriteException catch (err, st) {
      return left(Failure(
          err.message ?? "something went wrong while retweeting",
          st.toString()));
    } catch (e, st) {
      return left(Failure(e.toString(), st.toString()));
    }
  }

  @override
  Future<List<Document>> getRepliesToTweet(Tweet tweet) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        queries: [
          Query.equal(
            'repliedTo',
            tweet.id,
          ),
        ]);

    return documents.documents;
  }

  @override
  Future<Document> getTweetById(String id) async {
    Document document = await _db.getDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        documentId: id);

    return document;
  }

  @override
  Future<List<Document>> getUserTweets(String uid) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        queries: [Query.equal('uid', uid)]);
    return documents.documents;
  }

  @override
  Future<List<Document>> getTweetsByHastag(String hashtag) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollections,
        queries: [Query.search('hashtags', hashtag)]);
    return documents.documents;
  }
}
