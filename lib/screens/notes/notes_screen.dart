import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/notes_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/note_card.dart';
import '../../widgets/empty_state.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNote(BuildContext context, {String? noteId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: noteId)),
    );
  }

  Future<void> _deleteNote(BuildContext context, String id) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.translate('delete')),
        content: Text(l.translate('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<NotesProvider>().deleteNote(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.translate('deleteSuccess'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final provider = context.watch<NotesProvider>();
    final notes = _searchQuery.isEmpty
        ? provider.notes
        : provider.searchNotes(_searchQuery);

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        title: Text(l.translate('notes')),
        backgroundColor: AppColors.backgroundFor(context),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.notesColor.withOpacity(0.18),
                  AppColors.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderFor(context).withOpacity(0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.notesColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_rounded,
                    color: AppColors.notesColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.translate('notes'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryFor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أضف ملاحظاتك وأبقي أفكارك مرتبة بكل أناقة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceFor(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${notes.length}',
                    style: TextStyle(
                      color: AppColors.notesColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceFor(context),
                hintText: l.translate('searchHint'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textHintFor(context),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textHintFor(context),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? EmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: l.translate('noNotes'),
                    subtitle: l.translate('noNotesSub'),
                    iconColor: AppColors.notesColor,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 350),
                          child: SlideAnimation(
                            verticalOffset: 30,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Dismissible(
                                  key: Key(note.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _deleteNote(context, note.id);
                                    return false;
                                  },
                                  child: NoteCard(
                                    note: note,
                                    onTap: () =>
                                        _openNote(context, noteId: note.id),
                                    onFavorite: () => context
                                        .read<NotesProvider>()
                                        .toggleFavorite(note),
                                    onDelete: () =>
                                        _deleteNote(context, note.id),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
