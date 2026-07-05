import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/voice_note_model.dart';
import '../services/hive_service.dart';
import '../core/constants.dart';

class VoiceNotesProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<VoiceNoteModel> get voiceNotes {
    final list = HiveService.voiceNotesBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<VoiceNoteModel> get favorites =>
      voiceNotes.where((v) => v.isFavorite).toList();

  List<VoiceNoteModel> get recent => voiceNotes.take(5).toList();

  Future<String> getRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final voiceDir =
        Directory(p.join(appDir.path, AppConstants.voiceNotesDir));
    if (!await voiceDir.exists()) await voiceDir.create(recursive: true);
    return p.join(voiceDir.path, '${_uuid.v4()}.m4a');
  }

  Future<void> saveVoiceNote({
    required String title,
    required String filePath,
    required int durationSeconds,
    List<String> tags = const [],
    String? transcript,
  }) async {
    final note = VoiceNoteModel(
      id: _uuid.v4(),
      title: title.trim(),
      filePath: filePath,
      createdAt: DateTime.now(),
      durationSeconds: durationSeconds,
      tags: tags,
      transcript: transcript,
    );
    await HiveService.voiceNotesBox.put(note.id, note);
    notifyListeners();
  }

  Future<void> updateVoiceNote(VoiceNoteModel note) async {
    await HiveService.voiceNotesBox.put(note.id, note);
    notifyListeners();
  }

  Future<void> deleteVoiceNote(String id) async {
    final note = HiveService.voiceNotesBox.get(id);
    if (note != null) {
      final file = File(note.filePath);
      if (await file.exists()) await file.delete();
    }
    await HiveService.voiceNotesBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(VoiceNoteModel note) async {
    note.isFavorite = !note.isFavorite;
    await note.save();
    notifyListeners();
  }
}
