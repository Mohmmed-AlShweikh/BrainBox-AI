import 'package:hive/hive.dart';

part 'voice_note_model.g.dart';

@HiveType(typeId: 2)
class VoiceNoteModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String filePath;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late int durationSeconds;

  @HiveField(5)
  late List<String> tags;

  @HiveField(6)
  late bool isFavorite;

  @HiveField(7)
  late String? transcript;

  VoiceNoteModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.durationSeconds,
    this.tags = const [],
    this.isFavorite = false,
    this.transcript,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        (transcript?.toLowerCase().contains(q) ?? false) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'voice',
        'title': title,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'tags': tags,
        'isFavorite': isFavorite,
        'transcript': transcript,
      };
}
