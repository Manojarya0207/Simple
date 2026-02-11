import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Smart Bunker';
  static const String appVersion = '1.0.0';

  // Attendance Thresholds
  static const double excellentAttendance = 90.0;
  static const double goodAttendance = 75.0;
  static const double warningAttendance = 60.0;

  // Colors
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color dangerColor = Colors.red;
  static const Color infoColor = Colors.blue;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
  );

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Date Formats
  static const String dateFormatFull = 'EEEE, MMMM d, y';
  static const String dateFormatShort = 'MMM d, y';
  static const String dateFormatMonthYear = 'MMMM yyyy';
}