import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF141420);
  static const Color surfaceLight = Color(0xFF1E1E30);
  static const Color surfaceCard = Color(0xFF1A1A2E);
  static const Color surfaceElevated = Color(0xFF252540);

  // Primary Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);

  // Secondary Accents
  static const Color secondary = Color(0xFFEC4899); // Hot Pink
  static const Color secondaryLight = Color(0xFFF472B6);

  // Tertiary
  static const Color tertiary = Color(0xFF06B6D4); // Cyan
  static const Color tertiaryLight = Color(0xFF22D3EE);

  // Accent Colors
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonOrange = Color(0xFFF59E0B);
  static const Color neonRed = Color(0xFFEF4444);
  static const Color neonBlue = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusNotStarted = Color(0xFF6B7280);
  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusDone = Color(0xFF10B981);
  static const Color statusDelayed = Color(0xFFEF4444);

  // Severity
  static const Color severityLow = Color(0xFFF59E0B);
  static const Color severityMedium = Color(0xFFF97316);
  static const Color severityHigh = Color(0xFFEF4444);

  // Priority
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Emergency Contact Icons
  static const Color emergencyMedical = Color(0xFFEF4444);
  static const Color emergencyFire = Color(0xFFF97316);
  static const Color emergencyPolice = Color(0xFF3B82F6);
  static const Color emergencyVenue = Color(0xFF8B5CF6);
  static const Color emergencySecurity = Color(0xFF10B981);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF141420)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Staff role colors
  static const Map<String, Color> roleColors = {
    'Security': Color(0xFFEF4444),
    'Sound': Color(0xFF8B5CF6),
    'Lighting': Color(0xFFF59E0B),
    'Stage Crew': Color(0xFF06B6D4),
    'Volunteers': Color(0xFF10B981),
    'Event Manager': Color(0xFFEC4899),
    'Artist Manager': Color(0xFFF97316),
  };
}
