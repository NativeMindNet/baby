import 'package:flutter/material.dart';

/// App color palette for light and dark themes
class AppColors {
  // Light theme colors
  static const Color primaryLight = Color(0xFF6B9BD1);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1F2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Dark theme colors (for sleep activities and night mode)
  static const Color primaryDark = Color(0xFF4A7BA7);
  static const Color backgroundDark = Color(0xFF1A1F2E);
  static const Color surfaceDark = Color(0xFF2A2F3E);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);

  // Skill category colors
  static const Color regulationColor = Color(0xFF8B7EC8); // Purple
  static const Color attentionColor = Color(0xFF4A90E2); // Blue
  static const Color motorColor = Color(0xFFE28C4A); // Orange
  static const Color causeEffectColor = Color(0xFF50C878); // Green
  static const Color communicationColor = Color(0xFFE85D75); // Pink
  static const Color independenceColor = Color(0xFFFFB347); // Yellow-Orange

  // Feedback colors
  static const Color feedbackEasy = Color(0xFF10B981); // Green
  static const Color feedbackNormal = Color(0xFF6B7280); // Gray
  static const Color feedbackHard = Color(0xFFF59E0B); // Amber
  static const Color feedbackFailed = Color(0xFFEF4444); // Red
}
