import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/images_provider.dart';
import '../../providers/voice_notes_provider.dart';
import '../../providers/pdf_provider.dart';
import '../../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    try {
      final notesProvider = context.read<NotesProvider>();
      final imagesProvider = context.read<ImagesProvider>();
      final voiceProvider = context.read<VoiceNotesProvider>();
      final pdfProvider = context.read<PdfProvider>();

      final data = {
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': AppConstants.appVersion,
        'notes': notesProvider.notes.map((n) => n.toJson()).toList(),
        'images': imagesProvider.images.map((i) => i.toJson()).toList(),
        'voiceNotes': voiceProvider.voiceNotes.map((v) => v.toJson()).toList(),
        'pdfs': pdfProvider.pdfs.map((p) => p.toJson()).toList(),
      };

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/brainbox_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(data));

      await Share.shareXFiles([XFile(file.path)], text: 'BrainBox AI Export');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.translate('exportSuccess'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.translate('error')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final langProvider = context.watch<LanguageProvider>();
    final notesCount = context.watch<NotesProvider>().notes.length;
    final imagesCount = context.watch<ImagesProvider>().images.length;
    final voiceCount = context.watch<VoiceNotesProvider>().voiceNotes.length;
    final pdfCount = context.watch<PdfProvider>().pdfs.length;
    final totalCount = notesCount + imagesCount + voiceCount + pdfCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.translate('settingsTitle')),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // Profile / stats card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('appName'),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$totalCount ${l.translate('totalItems')}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance section
          _sectionHeader(l.translate('appearance')),
          _settingsCard(children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dark_mode_rounded,
                    color: AppColors.primary, size: 18),
              ),
              title: Text(
                l.translate('darkMode'),
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary, fontSize: 14),
              ),
              subtitle: Text(
                'Always enabled',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ON',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Language section
          _sectionHeader(l.translate('language')),
          _settingsCard(children: [
            ...AppConstants.languages.map((lang) {
              final isSelected = langProvider.locale.languageCode == lang['code'];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      lang['code'] == 'ar' ? 'ع' : 'En',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  lang['nativeName']!,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  lang['name']!,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () =>
                    context.read<LanguageProvider>().setLanguage(lang['code']!),
              );
            }),
          ]),

          const SizedBox(height: 16),

          // Data section
          _sectionHeader(l.translate('data')),
          _settingsCard(children: [
            _infoTile(
              title: l.translate('storageUsed'),
              subtitle:
                  '$notesCount notes · $imagesCount images · $voiceCount voice · $pdfCount PDFs',
              icon: Icons.storage_rounded,
            ),
            const Divider(color: AppColors.border, indent: 56, height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.upload_rounded,
                    color: AppColors.success, size: 18),
              ),
              title: Text(
                l.translate('exportData'),
                style:
                    GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
              ),
              subtitle: Text(
                l.translate('exportDataSub'),
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              onTap: () => _exportData(context),
            ),
          ]),

          const SizedBox(height: 16),

          // About section
          _sectionHeader(l.translate('about')),
          _settingsCard(children: [
            _infoTile(
              title: l.translate('appVersion'),
              subtitle: AppConstants.appVersion,
              icon: Icons.info_outline_rounded,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style:
            GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}
