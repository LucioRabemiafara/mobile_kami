import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../constants/colors.dart';

/// Service for showing notifications (SnackBars, Dialogs, etc.)
@lazySingleton
class NotificationService {
  /// Show a basic snackbar
  void showSnackBar(
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show success snackbar (green)
  void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      duration: duration,
    );
  }

  /// Show error snackbar (red)
  void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      duration: duration,
    );
  }

  /// Show warning snackbar (orange)
  void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      duration: duration,
    );
  }

  /// Show info snackbar (blue)
  void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      duration: duration,
    );
  }

  /// Show alert dialog
  Future<void> showAlertDialog(
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
  Future<bool> showConfirmationDialog(
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
            child: Text(
              cancelText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
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
  void showLoadingDialog(
    BuildContext context, {
    String message = 'Chargement...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Show error dialog
  Future<void> showErrorDialog(
    BuildContext context, {
    String title = 'Erreur',
    required String message,
  }) async {
    return showAlertDialog(
      context,
      title: title,
      message: message,
      confirmText: 'OK',
    );
  }

  /// Show success dialog
  Future<void> showSuccessDialog(
    BuildContext context, {
    String title = 'Succès',
    required String message,
    VoidCallback? onConfirm,
  }) async {
    return showAlertDialog(
      context,
      title: title,
      message: message,
      confirmText: 'OK',
      onConfirm: onConfirm,
    );
  }

  /// Show bottom sheet
  Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }
}
