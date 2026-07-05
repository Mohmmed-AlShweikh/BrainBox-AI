import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'appName': 'BrainBox AI',
      'search': 'Search',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'confirm': 'Confirm',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'noResults': 'No results found',
      'error': 'Error',
      'success': 'Success',
      'favorite': 'Favorite',
      'unfavorite': 'Unfavorite',
      'share': 'Share',
      'export': 'Export',
      'selectAll': 'Select All',
      'noData': 'Nothing here yet',
      'noDataSub': 'Tap + to add something new',
      'deleteConfirm': 'Are you sure you want to delete this?',
      'deleteSuccess': 'Deleted successfully',
      'addedFavorite': 'Added to favorites',
      'removedFavorite': 'Removed from favorites',

      // Navigation
      'home': 'Home',
      'notes': 'Notes',
      'images': 'Images',
      'voice': 'Voice',
      'pdfs': 'PDFs',
      'timeline': 'Timeline',
      'askBrainBox': 'Ask BrainBox',
      'settings': 'Settings',
      'search_nav': 'Search',

      // Home
      'goodMorning': 'Good morning',
      'goodAfternoon': 'Good afternoon',
      'goodEvening': 'Good evening',
      'yourMemory': 'Your Memory',
      'recentItems': 'Recent Items',
      'quickActions': 'Quick Actions',
      'totalItems': 'Total Items',
      'viewAll': 'View All',

      // Notes
      'newNote': 'New Note',
      'editNote': 'Edit Note',
      'noteTitle': 'Title',
      'noteContent': 'Content',
      'noteTitleHint': 'Enter note title...',
      'noteContentHint': 'Start writing...',
      'addTag': 'Add tag',
      'tags': 'Tags',
      'noNotes': 'No notes yet',
      'noNotesSub': 'Tap + to create your first note',
      'noteSaved': 'Note saved',

      // Images
      'newImage': 'New Image',
      'imageDescription': 'Description',
      'imageDescriptionHint': 'Describe this image...',
      'pickFromGallery': 'Pick from Gallery',
      'takePhoto': 'Take Photo',
      'noImages': 'No images yet',
      'noImagesSub': 'Tap + to save your first image',
      'imageSaved': 'Image saved',
      'addDescription': 'Add Description',

      // Voice Notes
      'newVoiceNote': 'New Voice Note',
      'voiceNoteTitle': 'Voice Note Title',
      'voiceTitleHint': 'Enter title...',
      'recording': 'Recording...',
      'tapToRecord': 'Tap to Record',
      'tapToStop': 'Tap to Stop',
      'play': 'Play',
      'pause': 'Pause',
      'stop': 'Stop',
      'duration': 'Duration',
      'noVoiceNotes': 'No voice notes yet',
      'noVoiceNotesSub': 'Tap + to record your first voice note',
      'voiceNoteSaved': 'Voice note saved',
      'permissionDenied': 'Microphone permission denied',
      'permissionRequired': 'Permission Required',
      'microphonePermission': 'Microphone permission is required to record voice notes.',

      // PDFs
      'newPdf': 'New PDF',
      'pdfTitle': 'PDF Title',
      'pdfTitleHint': 'Enter title...',
      'pickPdf': 'Pick PDF File',
      'viewPdf': 'View PDF',
      'noPdfs': 'No PDFs yet',
      'noPdfsSub': 'Tap + to save your first PDF',
      'pdfSaved': 'PDF saved',
      'pdfDescription': 'Description',
      'pdfDescHint': 'Add a description...',
      'pages': 'pages',

      // Timeline
      'timelineTitle': 'Timeline',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'thisWeek': 'This Week',
      'older': 'Older',
      'noTimeline': 'Your timeline is empty',
      'noTimelineSub': 'Start adding notes, images, or voice records',

      // Search
      'searchHint': 'Search notes, images, voice, PDFs...',
      'searchResults': 'Search Results',
      'filterAll': 'All',
      'filterNotes': 'Notes',
      'filterImages': 'Images',
      'filterVoice': 'Voice',
      'filterPdfs': 'PDFs',
      'startSearching': 'Start searching...',
      'startSearchingSub': 'Search across all your saved memories',

      // Ask BrainBox
      'askTitle': 'Ask BrainBox',
      'askHint': 'Ask anything about your saved memories...',
      'askButton': 'Ask',
      'thinking': 'Searching your memories...',
      'noAnswer': 'No matching memories found',
      'noAnswerSub': 'Try different keywords or check your saved content',
      'foundResults': 'Found {count} matching result(s)',
      'askWelcome': 'What would you like to find?',
      'askWelcomeSub': 'I\'ll search through all your notes, images, and files to find what you need.',
      'exampleQueries': 'Try asking:',

      // Settings
      'settingsTitle': 'Settings',
      'appearance': 'Appearance',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'data': 'Data & Storage',
      'exportData': 'Export All Data',
      'exportDataSub': 'Export everything as JSON',
      'storageUsed': 'Storage Used',
      'clearCache': 'Clear Cache',
      'about': 'About',
      'appVersion': 'App Version',
      'feedback': 'Send Feedback',
      'privacyPolicy': 'Privacy Policy',
      'exportSuccess': 'Data exported successfully',
    },
    'ar': {
      // General
      'appName': 'BrainBox AI',
      'search': 'بحث',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'loading': 'جارٍ التحميل...',
      'noResults': 'لا توجد نتائج',
      'error': 'خطأ',
      'success': 'نجح',
      'favorite': 'المفضلة',
      'unfavorite': 'إزالة من المفضلة',
      'share': 'مشاركة',
      'export': 'تصدير',
      'selectAll': 'تحديد الكل',
      'noData': 'لا يوجد شيء هنا بعد',
      'noDataSub': 'اضغط + لإضافة شيء جديد',
      'deleteConfirm': 'هل أنت متأكد من الحذف؟',
      'deleteSuccess': 'تم الحذف بنجاح',
      'addedFavorite': 'تمت الإضافة إلى المفضلة',
      'removedFavorite': 'تمت الإزالة من المفضلة',

      // Navigation
      'home': 'الرئيسية',
      'notes': 'الملاحظات',
      'images': 'الصور',
      'voice': 'التسجيل',
      'pdfs': 'ملفات PDF',
      'timeline': 'الجدول الزمني',
      'askBrainBox': 'اسأل BrainBox',
      'settings': 'الإعدادات',
      'search_nav': 'بحث',

      // Home
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'مساء الخير',
      'goodEvening': 'مساء النور',
      'yourMemory': 'ذاكرتك',
      'recentItems': 'العناصر الأخيرة',
      'quickActions': 'إجراءات سريعة',
      'totalItems': 'إجمالي العناصر',
      'viewAll': 'عرض الكل',

      // Notes
      'newNote': 'ملاحظة جديدة',
      'editNote': 'تعديل الملاحظة',
      'noteTitle': 'العنوان',
      'noteContent': 'المحتوى',
      'noteTitleHint': 'أدخل عنوان الملاحظة...',
      'noteContentHint': 'ابدأ الكتابة...',
      'addTag': 'إضافة وسم',
      'tags': 'الوسوم',
      'noNotes': 'لا توجد ملاحظات بعد',
      'noNotesSub': 'اضغط + لإنشاء أول ملاحظة',
      'noteSaved': 'تم حفظ الملاحظة',

      // Images
      'newImage': 'صورة جديدة',
      'imageDescription': 'الوصف',
      'imageDescriptionHint': 'صف هذه الصورة...',
      'pickFromGallery': 'اختر من المعرض',
      'takePhoto': 'التقط صورة',
      'noImages': 'لا توجد صور بعد',
      'noImagesSub': 'اضغط + لحفظ أول صورة',
      'imageSaved': 'تم حفظ الصورة',
      'addDescription': 'إضافة وصف',

      // Voice Notes
      'newVoiceNote': 'تسجيل صوتي جديد',
      'voiceNoteTitle': 'عنوان التسجيل',
      'voiceTitleHint': 'أدخل عنوانًا...',
      'recording': 'جارٍ التسجيل...',
      'tapToRecord': 'اضغط للتسجيل',
      'tapToStop': 'اضغط للإيقاف',
      'play': 'تشغيل',
      'pause': 'إيقاف مؤقت',
      'stop': 'إيقاف',
      'duration': 'المدة',
      'noVoiceNotes': 'لا توجد تسجيلات صوتية بعد',
      'noVoiceNotesSub': 'اضغط + لإنشاء أول تسجيل',
      'voiceNoteSaved': 'تم حفظ التسجيل الصوتي',
      'permissionDenied': 'تم رفض إذن الميكروفون',
      'permissionRequired': 'الإذن مطلوب',
      'microphonePermission': 'يلزم إذن الميكروفون لتسجيل الملاحظات الصوتية.',

      // PDFs
      'newPdf': 'ملف PDF جديد',
      'pdfTitle': 'عنوان الملف',
      'pdfTitleHint': 'أدخل عنوانًا...',
      'pickPdf': 'اختر ملف PDF',
      'viewPdf': 'عرض PDF',
      'noPdfs': 'لا توجد ملفات PDF بعد',
      'noPdfsSub': 'اضغط + لحفظ أول ملف',
      'pdfSaved': 'تم حفظ الملف',
      'pdfDescription': 'الوصف',
      'pdfDescHint': 'أضف وصفًا...',
      'pages': 'صفحة',

      // Timeline
      'timelineTitle': 'الجدول الزمني',
      'today': 'اليوم',
      'yesterday': 'أمس',
      'thisWeek': 'هذا الأسبوع',
      'older': 'أقدم',
      'noTimeline': 'الجدول الزمني فارغ',
      'noTimelineSub': 'ابدأ بإضافة ملاحظات أو صور أو تسجيلات',

      // Search
      'searchHint': 'ابحث في الملاحظات والصور والتسجيلات...',
      'searchResults': 'نتائج البحث',
      'filterAll': 'الكل',
      'filterNotes': 'ملاحظات',
      'filterImages': 'صور',
      'filterVoice': 'صوت',
      'filterPdfs': 'PDF',
      'startSearching': 'ابدأ البحث...',
      'startSearchingSub': 'ابحث في جميع ذكرياتك المحفوظة',

      // Ask BrainBox
      'askTitle': 'اسأل BrainBox',
      'askHint': 'اسأل أي شيء عن ذكرياتك المحفوظة...',
      'askButton': 'اسأل',
      'thinking': 'جارٍ البحث في ذاكرتك...',
      'noAnswer': 'لم يتم العثور على ذكريات مطابقة',
      'noAnswerSub': 'جرب كلمات مختلفة أو تحقق من محتواك المحفوظ',
      'foundResults': 'تم العثور على {count} نتيجة مطابقة',
      'askWelcome': 'ماذا تريد أن تجد؟',
      'askWelcomeSub': 'سأبحث في جميع ملاحظاتك وصورك وملفاتك للعثور على ما تحتاجه.',
      'exampleQueries': 'جرب السؤال:',

      // Settings
      'settingsTitle': 'الإعدادات',
      'appearance': 'المظهر',
      'darkMode': 'الوضع الداكن',
      'language': 'اللغة',
      'selectLanguage': 'اختر اللغة',
      'data': 'البيانات والتخزين',
      'exportData': 'تصدير جميع البيانات',
      'exportDataSub': 'تصدير كل شيء بتنسيق JSON',
      'storageUsed': 'المساحة المستخدمة',
      'clearCache': 'مسح الذاكرة المؤقتة',
      'about': 'حول التطبيق',
      'appVersion': 'إصدار التطبيق',
      'feedback': 'إرسال ملاحظات',
      'privacyPolicy': 'سياسة الخصوصية',
      'exportSuccess': 'تم تصدير البيانات بنجاح',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String translateWithArgs(String key, Map<String, String> args) {
    String text = translate(key);
    args.forEach((argKey, value) {
      text = text.replaceAll('{$argKey}', value);
    });
    return text;
  }

  bool get isRtl => locale.languageCode == 'ar';
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
