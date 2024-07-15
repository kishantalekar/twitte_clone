import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

String getNameFromUser(String email) {
  return email.split('@')[0];
}

Future<List<File>> pickImages() async {
  List<File> images = [];

  final ImagePicker picker = ImagePicker();

  final imagefiles = await picker.pickMultiImage();

  if (imagefiles.isNotEmpty) {
    for (final image in imagefiles) {
      images.add(File(image.path));
    }
  }
  return images;
}

Future<File?> pickImage() async {
  final ImagePicker picker = ImagePicker();

  final imagefile = await picker.pickImage(
    source: ImageSource.gallery,
  );
  if (imagefile != null) {
    return File(imagefile.path);
  }
  return null;
}
