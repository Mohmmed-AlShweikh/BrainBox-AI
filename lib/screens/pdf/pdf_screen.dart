import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/pdf_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/pdf_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tag_chip.dart';
import 'pdf_viewer_screen.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  Future<void> _pickPdf(BuildContext context) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null && context.mounted) {
        _showSaveDialog(context, result.files.single.path!,
            result.files.single.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.translate('error')}: $e')),
        );
      }
    }
  }

  void _showSaveDialog(BuildContext ctx, String path, String filename) {
    final l = AppLocalizations(ctx.read<LanguageProvider>().locale);
    final titleController = TextEditingController(
      text: filename.replaceAll('.pdf', ''),
    );
    final descController = TextEditingController();
    final List<String> tags = [];
    final tagController = TextEditingController();

    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l.translate('newPdf'),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: l.translate('pdfTitleHint'),
                    labelText: l.translate('pdfTitle'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l.translate('pdfDescHint'),
                    labelText: l.translate('pdfDescription'),
                  ),
                ),
                const SizedBox(height: 12),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map((t) => TagChip(
                              label: t,
                              onDelete: () =>
                                  setSheetState(() => tags.remove(t)),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagController,
                        decoration: InputDecoration(
                          hintText: l.translate('addTag'),
                          prefixText: '# ',
                        ),
                        onSubmitted: (v) {
                          final trimmed = v.trim().toLowerCase();
                          if (trimmed.isNotEmpty && !tags.contains(trimmed)) {
                            setSheetState(() => tags.add(trimmed));
                          }
                          tagController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        final trimmed =
                            tagController.text.trim().toLowerCase();
                        if (trimmed.isNotEmpty && !tags.contains(trimmed)) {
                          setSheetState(() => tags.add(trimmed));
                        }
                        tagController.clear();
                      },
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.pdfColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      await ctx.read<PdfProvider>().addPdf(
                            title: titleController.text.trim().isEmpty
                                ? filename
                                : titleController.text.trim(),
                            sourcePath: path,
                            description: descController.text.trim(),
                            tags: tags,
                          );
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(l.translate('pdfSaved'))),
                        );
                      }
                    },
                    child: Text(l.translate('save')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePdf(BuildContext context, String id) async {
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
      await context.read<PdfProvider>().deletePdf(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final pdfs = context.watch<PdfProvider>().pdfs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.translate('pdfs')),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => _pickPdf(context),
          ),
        ],
      ),
      body: pdfs.isEmpty
          ? EmptyState(
              icon: Icons.picture_as_pdf_outlined,
              title: l.translate('noPdfs'),
              subtitle: l.translate('noPdfsSub'),
              iconColor: AppColors.pdfColor,
            )
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: pdfs.length,
                itemBuilder: (context, index) {
                  final pdf = pdfs[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 350),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key(pdf.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.error),
                            ),
                            confirmDismiss: (_) async {
                              await _deletePdf(context, pdf.id);
                              return false;
                            },
                            child: PdfCard(
                              pdf: pdf,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(pdf: pdf),
                                ),
                              ),
                              onFavorite: () => context
                                  .read<PdfProvider>()
                                  .toggleFavorite(pdf),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickPdf(context),
        child: const Icon(Icons.upload_file_rounded),
      ),
    );
  }
}
