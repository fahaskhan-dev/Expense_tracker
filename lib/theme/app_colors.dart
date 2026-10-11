import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradients - Vibrant Purple & Blue
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color deepIndigo = Color(0xFF4834D4);
  static const Color electricBlue = Color(0xFF0984E3);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color softPurple = Color(0xFFA29BFE);
  
  // Hero Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C5CE7),
      Color(0xFF3B82F6),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5B4BC4),
      Color(0xFF2563EB),
    ],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );

  // Status & Financial Colors
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color incomeGreenLight = Color(0xFFD1FAE5);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color expenseRedLight = Color(0xFFFEE2E2);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberLight = Color(0xFFFEF3C7);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueLight = Color(0xFFDBEAFE);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF4F6FC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightInputFill = Color(0xFFF8FAFC);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F111A);
  static const Color darkCardBackground = Color(0xFF1A1D2E);
  static const Color darkCardElevated = Color(0xFF24283E);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF2E344E);
  static const Color darkInputFill = Color(0xFF161928);
}
