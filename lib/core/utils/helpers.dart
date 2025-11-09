import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

/// Utility class for helper functions
class Helpers {
  // Prevent instantiation
  Helpers._();

  /// Show snackbar with message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
    );
  }

  /// Show dialog with title and message
  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog with Yes/No buttons
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Oui',
    String cancelText = 'Non',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? 'Chargement...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Trigger haptic feedback (vibration)
  static void triggerHapticFeedback({HapticFeedbackType type = HapticFeedbackType.light}) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Trigger success haptic feedback
  static void triggerSuccessFeedback() {
    triggerHapticFeedback(type: HapticFeedbackType.medium);
  }

  /// Trigger error haptic feedback
  static void triggerErrorFeedback() {
    triggerHapticFeedback(type: HapticFeedbackType.heavy);
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Get initials from name (Jean Dupont -> JD)
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is late (after 9:00 AM)
  static bool isLate(DateTime time) {
    return time.hour >= 9;
  }

  /// Get time of day from DateTime
  static TimeOfDay getTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Convert TimeOfDay to DateTime (with today's date)
  static DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  /// Calculate duration between two times
  static Duration calculateDuration(DateTime start, DateTime end) {
    return end.difference(start);
  }

  /// Calculate hours worked (in hours as double)
  static double calculateHoursWorked(DateTime checkIn, DateTime checkOut) {
    final duration = checkOut.difference(checkIn);
    return duration.inMinutes / 60.0;
  }

  /// Check if user has access to zone (multi-posts)
  /// Returns true if at least ONE of user's posts is in zone's allowedPosts
  static bool hasAccessToZone(List<String> userPosts, List<String> allowedPosts) {
    if (allowedPosts.isEmpty) return true; // Zone open to all

    for (final post in userPosts) {
      if (allowedPosts.contains(post)) {
        return true;
      }
    }

    return false;
  }

  /// Get first matching post (multi-posts)
  /// Returns the first post that matches between user and zone
  static String? getFirstMatchingPost(List<String> userPosts, List<String> allowedPosts) {
    for (final post in userPosts) {
      if (allowedPosts.contains(post)) {
        return post;
      }
    }
    return null;
  }

  /// Navigate to route and remove all previous routes
  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.of(context).pop(result);
  }

  /// Pop until first route (dashboard)
  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Delay execution
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  /// Copy text to clipboard
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// Generate random color
  static Color generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;

    return Color.fromRGBO(r, g, b, 1.0);
  }

  /// Format QR code (for display)
  static String formatQRCode(String qrCode) {
    if (qrCode.length <= 20) return qrCode;
    return '${qrCode.substring(0, 10)}...${qrCode.substring(qrCode.length - 10)}';
  }

  /// Check if account is locked
  static bool isAccountLocked(DateTime? lockedUntil) {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil);
  }

  /// Get remaining lock time
  static Duration? getRemainingLockTime(DateTime? lockedUntil) {
    if (lockedUntil == null) return null;
    if (!isAccountLocked(lockedUntil)) return null;
    return lockedUntil.difference(DateTime.now());
  }
}

/// Haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}
