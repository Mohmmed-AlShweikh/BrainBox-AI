import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../providers/notes_provider.dart';
import '../providers/images_provider.dart';
import '../providers/voice_notes_provider.dart';
import '../providers/pdf_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/stat_card.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import 'search/search_screen.dart';
import 'timeline/timeline_screen.dart';
import 'ask/ask_brainbox_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'goodMorning';
    if (hour < 17) return 'goodAfternoon';
    return 'goodEvening';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final notes = context.watch<NotesProvider>();
    final images = context.watch<ImagesProvider>();
    final voice = context.watch<VoiceNotesProvider>();
    final pdfs = context.watch<PdfProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.translate(_greeting()),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              l.translate('appName'),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _iconButton(
                              icon: Icons.search_rounded,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SearchScreen())),
                            ),
                            const SizedBox(width: 8),
                            _iconButton(
                              icon: Icons.settings_outlined,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    StatCard(
                      label: l.translate('notes'),
                      count: notes.notes.length.toString(),
                      icon: Icons.sticky_note_2_rounded,
                      color: AppColors.notesColor,
                    ),
                    StatCard(
                      label: l.translate('images'),
                      count: images.images.length.toString(),
                      icon: Icons.photo_rounded,
                      color: AppColors.imagesColor,
                    ),
                    StatCard(
                      label: l.translate('voice'),
                      count: voice.voiceNotes.length.toString(),
                      icon: Icons.mic_rounded,
                      color: AppColors.voiceColor,
                    ),
                    StatCard(
                      label: l.translate('pdfs'),
                      count: pdfs.pdfs.length.toString(),
                      icon: Icons.picture_as_pdf_rounded,
                      color: AppColors.pdfColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick actions
                Text(
                  l.translate('quickActions'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _quickAction(
                        icon: Icons.timeline_rounded,
                        label: l.translate('timeline'),
                        color: AppColors.timelineColor,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const TimelineScreen())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickAction(
                        icon: Icons.psychology_rounded,
                        label: l.translate('askBrainBox'),
                        color: AppColors.askColor,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AskBrainBoxScreen())),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent notes
                if (notes.notes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.translate('recentItems'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...notes.recent.map((note) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NoteCard(
                          note: note,
                          onTap: () {},
                          onFavorite: () =>
                              context.read<NotesProvider>().toggleFavorite(note),
                        ),
                      )),
                ] else ...[
                  const SizedBox(height: 24),
                  EmptyState(
                    icon: Icons.psychology_outlined,
                    title: l.translate('noData'),
                    subtitle: l.translate('noDataSub'),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
