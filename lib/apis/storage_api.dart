import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/core/providers.dart';

final storageApiProvider = Provider((ref) {
  final storage = ref.watch(appwriteStorageProvider);
  return StorageApi(storage: storage);
});

class StorageApi {
  StorageApi({required Storage storage}) : _storage = storage;
  final Storage _storage;

  Future<List<String>> uploadImage(List<File> files) async {
    List<String> imageLinks = [];

    for (final file in files) {
      final uploadImage = await _storage.createFile(
          bucketId: AppWriteConstants.bucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: file.path));
      imageLinks.add(
        AppWriteConstants.imageUrl(uploadImage.$id),
      );
    }
    return imageLinks;
  }

  Future<String> uploadSingleImage(File file) async {
    final uploadImage = await _storage.createFile(
        bucketId: AppWriteConstants.bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path));
    return AppWriteConstants.imageUrl(uploadImage.$id);
  }
}
