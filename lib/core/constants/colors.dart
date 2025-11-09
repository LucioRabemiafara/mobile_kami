import 'package:flutter/material.dart';

/// Application Color Palette
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Bleu
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Secondary Colors
  static const Color secondary = Color(0xFF388E3C); // Vert
  static const Color secondaryLight = Color(0xFF6ABF69);
  static const Color secondaryDark = Color(0xFF00600F);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Vert
  static const Color error = Color(0xFFE53935); // Rouge
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Bleu clair

  // Security Level Colors
  static const Color securityLow = Color(0xFF81C784); // Vert clair
  static const Color securityMedium = Color(0xFFFFB74D); // Orange clair
  static const Color securityHigh = Color(0xFFE57373); // Rouge clair

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Gris clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Access Screen Backgrounds
  static const Color accessGrantedBackground = Color(0xFFE8F5E9); // Vert tr\u00e8s clair
  static const Color accessDeniedBackground = Color(0xFFFFEBEE); // Rouge tr\u00e8s clair

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Noir
  static const Color textSecondary = Color(0xFF757575); // Gris
  static const Color textHint = Color(0xFFBDBDBD); // Gris clair
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color textOnSecondary = Color(0xFFFFFFFF); // Blanc

  // Divider & Border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Card & Container
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1F000000);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFE0E0E0);

  // Input Colors
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusedBorder = primary;
  static const Color inputErrorBorder = error;

  // Badge Colors
  static const Color badgeOnTime = Color(0xFF4CAF50);
  static const Color badgeLate = Color(0xFFFF9800);
  static const Color badgePending = Color(0xFFFF9800);
  static const Color badgeApproved = Color(0xFF4CAF50);
  static const Color badgeRejected = Color(0xFFE53935);

  // Chart Colors
  static const Color chartPrimary = Color(0xFF1976D2);
  static const Color chartSecondary = Color(0xFF388E3C);
  static const Color chartGrid = Color(0xFFE0E0E0);

  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper Methods
  static Color getSecurityLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return securityLow;
      case 'MEDIUM':
        return securityMedium;
      case 'HIGH':
        return securityHigh;
      default:
        return securityMedium;
    }
  }

  static Color getRequestStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return badgePending;
      case 'APPROVED':
        return badgeApproved;
      case 'REJECTED':
        return badgeRejected;
      default:
        return badgePending;
    }
  }

  static Color getAttendanceStatusColor(bool isLate) {
    return isLate ? badgeLate : badgeOnTime;
  }
}
