import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/note_model.dart';
import 'tag_chip.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardFor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderFor(context), width: 1),
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
            // Color accent bar
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryFor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavorite != null)
                        GestureDetector(
                          onTap: onFavorite,
                          child: Icon(
                            note.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 18,
                            color: note.isFavorite
                                ? AppColors.warning
                                : AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryFor(context),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: note.tags
                          .take(3)
                          .map((tag) => TagChip(label: tag))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(note.updatedAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHintFor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
