import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/tag_chip.dart';

class NoteDetailScreen extends StatefulWidget {
  final String? noteId;
  const NoteDetailScreen({super.key, this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isEdited = false;
  NoteModel? _existingNote;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      final provider = context.read<NotesProvider>();
      _existingNote = provider.notes.firstWhere((n) => n.id == widget.noteId);
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
      _tags.addAll(_existingNote!.tags);
    }
    _titleController.addListener(() => setState(() => _isEdited = true));
    _contentController.addListener(() => setState(() => _isEdited = true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final l = AppLocalizations(context.read<LanguageProvider>().locale);

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();
    if (_existingNote != null) {
      final updated = _existingNote!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: _tags,
        updatedAt: DateTime.now(),
      );
      await provider.updateNote(updated);
    } else {
      await provider.addNote(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: _tags,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.translate('noteSaved'))));
      Navigator.pop(context);
    }
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isNotEmpty &&
        !_tags.contains(trimmed) &&
        _tags.length < AppConstants.maxTags &&
        trimmed.length <= AppConstants.maxTagLength) {
      setState(() {
        _tags.add(trimmed);
        _isEdited = true;
      });
    }
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final isNew = widget.noteId == null;

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundFor(context),
        title: Text(isNew ? l.translate('newNote') : l.translate('editNote')),
        actions: [
          if (_isEdited || isNew)
            TextButton(
              onPressed: _save,
              child: Text(
                l.translate('save'),
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.notesColor.withOpacity(0.16),
                    AppColors.primary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.borderFor(context).withOpacity(0.7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFor(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.sticky_note_2_rounded,
                      color: AppColors.notesColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isNew ? 'أنشئ ملاحظة جديدة' : 'عدّل ملاحظتك بوضوح',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardFor(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderFor(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                    decoration: InputDecoration(
                      hintText: l.translate('noteTitleHint'),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  TextField(
                    controller: _contentController,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textPrimaryFor(context),
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: l.translate('noteContentHint'),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    maxLines: null,
                    minLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardFor(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.translate('tags'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryFor(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map(
                            (tag) => TagChip(
                              label: tag,
                              onDelete: () => setState(() => _tags.remove(tag)),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimaryFor(context),
                          ),
                          decoration: InputDecoration(
                            hintText: l.translate('addTag'),
                            prefixText: '# ',
                            prefixStyle: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: _addTag,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addTag(_tagController.text),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
