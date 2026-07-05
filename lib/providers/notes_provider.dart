import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';

class NotesProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<NoteModel> get notes {
    final list = HiveService.notesBox.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<NoteModel> get favorites =>
      notes.where((n) => n.isFavorite).toList();

  List<NoteModel> get recent => notes.take(5).toList();

  List<NoteModel> searchNotes(String query) {
    if (query.trim().isEmpty) return notes;
    return notes.where((n) => n.matchesQuery(query)).toList();
  }

  List<NoteModel> filterByTag(String tag) {
    return notes.where((n) => n.tags.contains(tag)).toList();
  }

  Future<void> addNote({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final note = NoteModel(
      id: _uuid.v4(),
      title: title.trim(),
      content: content.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await HiveService.notesBox.put(note.id, note);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await HiveService.notesBox.put(updated.id, updated);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await HiveService.notesBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(NoteModel note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await HiveService.notesBox.put(updated.id, updated);
    notifyListeners();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }
}
