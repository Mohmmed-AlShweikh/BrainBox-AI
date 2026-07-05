import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/image_model.dart';
import '../services/hive_service.dart';
import '../core/constants.dart';

class ImagesProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<ImageModel> get images {
    final list = HiveService.imagesBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<ImageModel> get favorites =>
      images.where((i) => i.isFavorite).toList();

  List<ImageModel> get recent => images.take(5).toList();

  Future<void> addImage({
    required String title,
    required String sourcePath,
    required String description,
    List<String> tags = const [],
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir =
        Directory(p.join(appDir.path, AppConstants.imagesDir));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

    final id = _uuid.v4();
    final ext = p.extension(sourcePath);
    final destPath = p.join(imagesDir.path, '$id$ext');
    await File(sourcePath).copy(destPath);

    final image = ImageModel(
      id: id,
      title: title.trim(),
      filePath: destPath,
      description: description.trim(),
      createdAt: DateTime.now(),
      tags: tags,
    );
    await HiveService.imagesBox.put(image.id, image);
    notifyListeners();
  }

  Future<void> updateImage(ImageModel image) async {
    await HiveService.imagesBox.put(image.id, image);
    notifyListeners();
  }

  Future<void> deleteImage(String id) async {
    final image = HiveService.imagesBox.get(id);
    if (image != null) {
      final file = File(image.filePath);
      if (await file.exists()) await file.delete();
    }
    await HiveService.imagesBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(ImageModel image) async {
    image.isFavorite = !image.isFavorite;
    await image.save();
    notifyListeners();
  }
}
