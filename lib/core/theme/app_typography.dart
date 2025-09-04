import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Defines the typography styles for the UMaT E-Health App.
///
/// This class contains all the text styles used throughout the application
/// to ensure consistency in the UI design. All styles use default Flutter fonts.
class AppTypography {
  // Primary font family - Using default Flutter fonts
  static final TextStyle _baseStyle = const TextStyle();

  // Secondary font family - Using default Flutter fonts for headings
  static final TextStyle _headingStyle = const TextStyle();

  // Headings - Using default fonts for impact and readability
  static final TextStyle heading1 = _headingStyle.copyWith(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static final TextStyle heading2 = _headingStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static final TextStyle heading3 = _headingStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static final TextStyle heading4 = _headingStyle.copyWith(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static final TextStyle heading5 = _headingStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body text - Using default fonts for excellent readability
  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Button text - Clear and actionable
  static final TextStyle buttonText = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Input fields - Readable and accessible
  static final TextStyle inputText = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Labels - Clear hierarchy
  static final TextStyle label = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Captions - Subtle but readable
  static final TextStyle caption = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  // Links - Clearly interactive
  static final TextStyle link = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: 1.4,
  );

  // Helper methods to modify text styles

  /// Returns a copy of the style with bold weight
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Returns a copy of the style with medium weight
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  /// Returns a copy of the style with the specified color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
