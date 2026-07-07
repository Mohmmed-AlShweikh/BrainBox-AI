import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/image_model.dart';

class ImageCard extends StatelessWidget {
  final ImageModel image;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const ImageCard({
    super.key,
    required this.image,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(image.filePath);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardFor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.imagesColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: file.existsSync()
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.surfaceFor(context),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textHintFor(context),
                          size: 40,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          image.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
                            image.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: image.isFavorite
                                ? AppColors.warning
                                : AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                  if (image.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      image.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryFor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(image.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHint,
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
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
