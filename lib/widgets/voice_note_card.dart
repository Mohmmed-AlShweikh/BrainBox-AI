import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/voice_note_model.dart';

class VoiceNoteCard extends StatelessWidget {
  final VoiceNoteModel voiceNote;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const VoiceNoteCard({
    super.key,
    required this.voiceNote,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Play icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.voiceColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.voiceColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voiceNote.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavorite != null)
                        GestureDetector(
                          onTap: onFavorite,
                          child: Icon(
                            voiceNote.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: voiceNote.isFavorite
                                ? AppColors.warning
                                : AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        voiceNote.formattedDuration,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(voiceNote.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  // Waveform decoration
                  const SizedBox(height: 8),
                  _buildWaveform(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    final heights = [4.0, 8.0, 12.0, 6.0, 10.0, 14.0, 8.0, 5.0, 11.0, 7.0,
        9.0, 13.0, 6.0, 10.0, 4.0, 8.0, 12.0, 7.0, 5.0, 9.0];
    return Row(
      children: heights.map((h) {
        return Container(
          width: 2.5,
          height: h,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: AppColors.voiceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
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
