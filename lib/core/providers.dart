import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/constants/constants.dart';

final appwriteClientProvider = Provider((ref) {
  final client = Client();
  return client
      .setEndpoint(AppWriteConstants.endPoint)
      .setProject(AppWriteConstants.projectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});
final appwriteRealtimeProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});
final appwriteRealtimeProviderForProfile = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});

final appwriteRealtimeProviderForNotification = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});
