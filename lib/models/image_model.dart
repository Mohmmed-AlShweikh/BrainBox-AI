import 'package:hive/hive.dart';

part 'image_model.g.dart';

@HiveType(typeId: 1)
class ImageModel extends HiveObject {
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
  late List<String> tags;

  @HiveField(6)
  late bool isFavorite;

  @HiveField(7)
  late String? extractedText;

  ImageModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.description,
    required this.createdAt,
    this.tags = const [],
    this.isFavorite = false,
    this.extractedText,
  });

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        (extractedText?.toLowerCase().contains(q) ?? false) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'image',
        'title': title,
        'filePath': filePath,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'tags': tags,
        'isFavorite': isFavorite,
        'extractedText': extractedText,
      };
}
