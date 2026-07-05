import 'package:hive/hive.dart';

part 'pdf_model.g.dart';

@HiveType(typeId: 3)
class PdfModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String filePath;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late int pages;

  @HiveField(6)
  late List<String> tags;

  @HiveField(7)
  late bool isFavorite;

  @HiveField(8)
  late int fileSizeBytes;

  PdfModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.description,
    required this.createdAt,
    this.pages = 0,
    this.tags = const [],
    this.isFavorite = false,
    this.fileSizeBytes = 0,
  });

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'pdf',
        'title': title,
        'filePath': filePath,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'pages': pages,
        'tags': tags,
        'isFavorite': isFavorite,
        'fileSizeBytes': fileSizeBytes,
      };
}
