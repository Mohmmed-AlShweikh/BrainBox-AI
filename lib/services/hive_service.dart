import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../models/image_model.dart';
import '../models/voice_note_model.dart';
import '../models/pdf_model.dart';
import '../core/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ImageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(VoiceNoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PdfModelAdapter());
    }

    // Open boxes
    await Hive.openBox<NoteModel>(AppConstants.notesBox);
    await Hive.openBox<ImageModel>(AppConstants.imagesBox);
    await Hive.openBox<VoiceNoteModel>(AppConstants.voiceNotesBox);
    await Hive.openBox<PdfModel>(AppConstants.pdfsBox);
    await Hive.openBox(AppConstants.settingsBox);
  }

  static Box<NoteModel> get notesBox =>
      Hive.box<NoteModel>(AppConstants.notesBox);
  static Box<ImageModel> get imagesBox =>
      Hive.box<ImageModel>(AppConstants.imagesBox);
  static Box<VoiceNoteModel> get voiceNotesBox =>
      Hive.box<VoiceNoteModel>(AppConstants.voiceNotesBox);
  static Box<PdfModel> get pdfsBox =>
      Hive.box<PdfModel>(AppConstants.pdfsBox);
  static Box get settingsBox => Hive.box(AppConstants.settingsBox);
}
