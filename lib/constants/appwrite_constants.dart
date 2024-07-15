class AppWriteConstants {
  static const String databaseId = "65a6b622ea4a981aae86";
  static const String projectId = '65a69fbc02b32cdc2ec4';
  static const String usersCollections = '65a7bdaf7ff9a1d7d740';
  static const String tweetCollections = '65a9617c493aea7d1a35';
  static const String notificationsCollections = '65ad5e8d71fa0ebc2003';
  static const String bucketId = '65aa02020f245c44605d';

  static const String endPoint = "http://localhost:80/v1";
  static String imageUrl(String imageId) =>
      "$endPoint/storage/buckets/$bucketId/files/$imageId/view?project=$projectId&mode=any";
}
