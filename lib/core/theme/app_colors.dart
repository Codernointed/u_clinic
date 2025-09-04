import 'package:flutter/material.dart';

/// Defines the color palette for the UMaT E-Health Application.
///
/// This class contains all the colors used throughout the healthcare application
/// to ensure consistency and accessibility in the medical UI design.
class AppColors {
  // Primary colors - Medical blue palette
  static const Color primary = Color.fromARGB(255, 51, 128, 68); // Medical teal/blue
  static const Color primaryDark = Color.fromARGB(255, 55, 145, 115); // Darker medical blue
  static const Color primaryLight = Color(0xFF4A9BAA); // Lighter medical blue
  static const Color secondary = Color(0xFF00BCD4); // Cyan accent

  // Background colors
  static const Color background = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFF8F9FA); // Very light gray
  static const Color surface = Color(0xFFF5F5F5); // Light gray

  // Text colors
  static const Color textPrimary = Color(
    0xFF212529,
  ); // Dark gray (better than black)
  static const Color textSecondary = Color(0xFF495057); // Medium dark gray
  static const Color textTertiary = Color(0xFF6C757D); // Medium gray
  static const Color textLight = Color(0xFFFFFFFF); // White text

  // Status colors - Medical appropriate
  static const Color success = Color(0xFF28A745); // Medical green
  static const Color error = Color(0xFFDC3545); // Medical red
  static const Color warning = Color(0xFFFFC107); // Medical yellow
  static const Color info = Color(0xFF17A2B8); // Medical info blue

  // Healthcare specific colors
  static const Color emergency = Color(0xFFE53E3E); // Emergency red
  static const Color urgent = Color(0xFFFF6B35); // Urgent orange
  static const Color routine = Color(0xFF38A169); // Routine green
  static const Color followUp = Color(0xFF3182CE); // Follow-up blue

  // Card colors for different sections
  static const Color cardAppointment = Color(0xFFE3F2FD); // Light blue
  static const Color cardMedicalRecord = Color(0xFFE8F5E8); // Light green
  static const Color cardEmergency = Color(0xFFFFEBEE); // Light red
  static const Color cardConsultation = Color(0xFFF3E5F5); // Light purple
  static const Color cardPrescription = Color(0xFFFFF3E0); // Light orange
  static const Color cardLabResult = Color(0xFFE1F5FE); // Light cyan

  // Role-based colors
  static const Color patient = Color(0xFF4CAF50); // Green for patients
  static const Color staff = Color(0xFF2196F3); // Blue for staff
  static const Color admin = Color(0xFF9C27B0); // Purple for admin
  static const Color adminDark = Color(0xFF7B1FA2); // Darker purple for admin

  // Department colors
  static const Color generalPractice = Color(0xFF4CAF50);
  static const Color internalMedicine = Color(0xFF2196F3);
  static const Color pediatrics = Color(0xFFFF9800);
  static const Color gynecology = Color(0xFFE91E63);
  static const Color psychiatry = Color(0xFF9C27B0);
  static const Color dentistry = Color(0xFF00BCD4);

  // Additional UI colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x0F000000); // 6% opacity black
  static const Color overlay = Color(0x80000000); // 50% opacity black
  static const Color shimmer = Color(0xFFE0E0E0);

  // Chart and graph colors
  static const List<Color> chartColors = [
    Color(0xFF2E7D8A),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
  ];

  // Accessibility colors
  static const Color highContrast = Color(0xFF000000);
  static const Color mediumContrast = Color(0xFF424242);
  static const Color lowContrast = Color(0xFF9E9E9E);

  // Legacy color mappings for backward compatibility
  // TODO: Remove these once all screens are updated
  static const Color cardGreen = cardMedicalRecord; // Maps to light green
  static const Color cardDeepGreen = routine; // Maps to routine green
  static const Color cardBlue = cardAppointment; // Maps to light blue
  static const Color cardOrange = cardPrescription; // Maps to light orange
  static const Color cardPurple = cardConsultation; // Maps to light purple
  static const Color cardRed = emergency; // Maps to emergency red
}
