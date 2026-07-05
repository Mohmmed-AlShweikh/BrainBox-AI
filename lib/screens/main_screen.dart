import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';
import 'home_screen.dart';
import 'notes/notes_screen.dart';
import 'images/images_screen.dart';
import 'voice/voice_notes_screen.dart';
import 'pdf/pdf_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    NotesScreen(),
    ImagesScreen(),
    VoiceNotesScreen(),
    PdfScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = AppLocalizations(lang.locale);

    return Directionality(
      textDirection:
          lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                label: l.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.sticky_note_2_outlined),
                activeIcon: const Icon(Icons.sticky_note_2_rounded),
                label: l.translate('notes'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.photo_outlined),
                activeIcon: const Icon(Icons.photo_rounded),
                label: l.translate('images'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.mic_none_rounded),
                activeIcon: const Icon(Icons.mic_rounded),
                label: l.translate('voice'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                activeIcon: const Icon(Icons.picture_as_pdf_rounded),
                label: l.translate('pdfs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
