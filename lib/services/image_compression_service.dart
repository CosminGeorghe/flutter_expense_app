import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {
  Future<File> compress(String imagePath) async {
    final compressedPath = '${imagePath}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      compressedPath,
      quality: 70,
      minWidth: 1500,
      minHeight: 1500,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }
}