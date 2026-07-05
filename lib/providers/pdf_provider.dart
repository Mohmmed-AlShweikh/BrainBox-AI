import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/pdf_model.dart';
import '../services/hive_service.dart';
import '../core/constants.dart';

class PdfProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<PdfModel> get pdfs {
    final list = HiveService.pdfsBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<PdfModel> get favorites => pdfs.where((p) => p.isFavorite).toList();

  List<PdfModel> get recent => pdfs.take(5).toList();

  Future<void> addPdf({
    required String title,
    required String sourcePath,
    required String description,
    List<String> tags = const [],
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfsDir =
        Directory(p.join(appDir.path, AppConstants.pdfsDir));
    if (!await pdfsDir.exists()) await pdfsDir.create(recursive: true);

    final id = _uuid.v4();
    final destPath = p.join(pdfsDir.path, '$id.pdf');
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    final fileSize = await sourceFile.length();

    final pdf = PdfModel(
      id: id,
      title: title.trim(),
      filePath: destPath,
      description: description.trim(),
      createdAt: DateTime.now(),
      tags: tags,
      fileSizeBytes: fileSize,
    );
    await HiveService.pdfsBox.put(pdf.id, pdf);
    notifyListeners();
  }

  Future<void> updatePdf(PdfModel pdf) async {
    await HiveService.pdfsBox.put(pdf.id, pdf);
    notifyListeners();
  }

  Future<void> deletePdf(String id) async {
    final pdf = HiveService.pdfsBox.get(id);
    if (pdf != null) {
      final file = File(pdf.filePath);
      if (await file.exists()) await file.delete();
    }
    await HiveService.pdfsBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(PdfModel pdf) async {
    pdf.isFavorite = !pdf.isFavorite;
    await pdf.save();
    notifyListeners();
  }
}
