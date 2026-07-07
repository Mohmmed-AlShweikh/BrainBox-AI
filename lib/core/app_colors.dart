import 'package:flutter/material.dart';

class AppColors {
  static Color backgroundFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? background
        : lightBackground;
  }

  static Color surfaceFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surface
        : lightSurface;
  }

  static Color cardFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? card : lightCard;
  }

  static Color borderFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? border
        : lightBorder;
  }

  static Color textPrimaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimary
        : lightTextPrimary;
  }

  static Color textSecondaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondary
        : lightTextSecondary;
  }

  static Color textHintFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textHint
        : lightTextHint;
  }

  // Dark theme palette
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141824);
  static const Color card = Color(0xFF1E2434);
  static const Color cardHover = Color(0xFF252D40);
  static const Color border = Color(0xFF2D3550);

  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D5FF7);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF472B6);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF475569);

  // Light theme palette
  static const Color lightBackground = Color(0xFFF5F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Module colors
  static const Color notesColor = Color(0xFF7C3AED);
  static const Color imagesColor = Color(0xFF06B6D4);
  static const Color voiceColor = Color(0xFFF472B6);
  static const Color pdfColor = Color(0xFFF59E0B);
  static const Color timelineColor = Color(0xFF22C55E);
  static const Color askColor = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF1a1040), Color(0xFF0A0E1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
