import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? color;

  const TagChip({
    super.key,
    required this.label,
    this.onDelete,
    this.onTap,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.25)
              : AppColors.cardFor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderFor(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$label',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? chipColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isSelected
                      ? chipColor
                      : AppColors.textSecondaryFor(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
