import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../core/constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isRtl => _locale.languageCode == 'ar';

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() {
    final saved = HiveService.settingsBox.get(AppConstants.languageKey);
    if (saved != null) {
      _locale = Locale(saved as String);
    }
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    HiveService.settingsBox.put(AppConstants.languageKey, languageCode);
    notifyListeners();
  }
}
