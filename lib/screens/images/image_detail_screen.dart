import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../models/image_model.dart';
import '../../providers/images_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/tag_chip.dart';

class ImageDetailScreen extends StatefulWidget {
  final String? sourcePath;
  final ImageModel? existingImage;

  const ImageDetailScreen({super.key, this.sourcePath, this.existingImage});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isSaving = false;

  String get _imagePath =>
      widget.sourcePath ?? widget.existingImage?.filePath ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.existingImage != null) {
      _titleController.text = widget.existingImage!.title;
      _descController.text = widget.existingImage!.description;
      _tags.addAll(widget.existingImage!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final title = _titleController.text.trim();

    try {
      if (widget.sourcePath != null) {
        await context.read<ImagesProvider>().addImage(
              title: title.isEmpty ? 'Image ${DateTime.now().millisecondsSinceEpoch}' : title,
              sourcePath: widget.sourcePath!,
              description: _descController.text.trim(),
              tags: _tags,
            );
      } else if (widget.existingImage != null) {
        widget.existingImage!.title = title.isEmpty ? 'Untitled' : title;
        widget.existingImage!.description = _descController.text.trim();
        widget.existingImage!.tags = _tags;
        await context.read<ImagesProvider>().updateImage(widget.existingImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.translate('imageSaved'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.translate('error')}: $e')),
        );
      }
    }
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isNotEmpty &&
        !_tags.contains(trimmed) &&
        _tags.length < AppConstants.maxTags) {
      setState(() => _tags.add(trimmed));
    }
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final imageFile = File(_imagePath);
    final isNew = widget.sourcePath != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(isNew ? l.translate('newImage') : l.translate('edit')),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (imageFile.existsSync())
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l.translate('noteTitleHint'),
                      labelText: l.translate('noteTitle'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextField(
                    controller: _descController,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: l.translate('imageDescriptionHint'),
                      labelText: l.translate('imageDescription'),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  Text(
                    l.translate('tags'),
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map((tag) => TagChip(
                                label: tag,
                                onDelete: () =>
                                    setState(() => _tags.remove(tag)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                              hintText: l.translate('addTag'),
                              prefixText: '# ',
                              prefixStyle: GoogleFonts.inter(
                                  color: AppColors.imagesColor)),
                          onSubmitted: _addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addTag(_tagController.text),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.imagesColor,
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
