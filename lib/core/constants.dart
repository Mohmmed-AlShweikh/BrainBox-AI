class AppConstants {
  // Hive box names
  static const String notesBox = 'notes_box';
  static const String imagesBox = 'images_box';
  static const String voiceNotesBox = 'voice_notes_box';
  static const String pdfsBox = 'pdfs_box';
  static const String settingsBox = 'settings_box';

  // Settings keys
  static const String themeKey = 'is_dark_mode';
  static const String languageKey = 'language_code';

  // App info
  static const String appName = 'BrainBox AI';
  static const String appVersion = '1.0.0';

  // Directories
  static const String voiceNotesDir = 'voice_notes';
  static const String imagesDir = 'images';
  static const String pdfsDir = 'pdfs';

  // Limits
  static const int maxTagLength = 20;
  static const int maxTags = 10;

  // Supported languages
  static const List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
  ];
}
