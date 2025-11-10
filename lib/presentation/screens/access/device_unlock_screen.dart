import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/camera_permission_service.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';
import '../../widgets/common/app_dialogs.dart';
import 'qr_scanner_screen.dart';

/// Device Unlock Screen
///
/// Requires native device authentication before QR scanning
/// Accepts ALL unlock methods: fingerprint, face, pattern, PIN, password
class DeviceUnlockScreen extends StatelessWidget {
  const DeviceUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AccessBloc>()..add(const DeviceUnlockRequested()),
      child: const _DeviceUnlockView(),
    );
  }
}

class _DeviceUnlockView extends StatefulWidget {
  const _DeviceUnlockView();

  @override
  State<_DeviceUnlockView> createState() => _DeviceUnlockViewState();
}

class _DeviceUnlockViewState extends State<_DeviceUnlockView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran pour le responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallHeight = screenHeight < 600;

    // Adaptation des tailles selon l'écran
    final iconContainerSize = isSmallScreen ? 100.0 : isVerySmallHeight ? 110.0 : 120.0;
    final iconSize = isSmallScreen ? 50.0 : isVerySmallHeight ? 55.0 : 60.0;
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final verticalSpacing1 = isVerySmallHeight ? 24.0 : 40.0;
    final verticalSpacing2 = isVerySmallHeight ? 32.0 : 48.0;
    final loadingSize = isSmallScreen ? 40.0 : 50.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Déverrouillage',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is DeviceUnlockInProgress) {
            AppDialogs.showLoading(
              context: context,
              message: 'Vérification du déverrouillage...',
            );
          } else if (state is DeviceUnlockSuccess) {
            AppDialogs.hide(context);
            AppDialogs.showSuccess(
              context: context,
              title: 'Déverrouillage Réussi',
              message: 'Vous pouvez maintenant scanner le QR code',
              buttonText: 'Continuer',
              barrierDismissible: false,
              onConfirm: () async {
                // Check camera permission before opening scanner
                final permissionService = CameraPermissionService();
                final hasPermission = await permissionService.ensureCameraPermission();

                if (hasPermission && context.mounted) {
                  // Navigate to QR scanner with proper bloc provision
                  // Use push instead of pushReplacement to keep BLoC alive
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AccessBloc>(),
                        child: const QRScannerScreen(),
                      ),
                    ),
                  );
                } else if (context.mounted) {
                  // Permission denied - show error
                  AppDialogs.showError(
                    context: context,
                    title: 'Permission Requise',
                    message: 'L\'accès à la caméra est nécessaire pour scanner le QR code.\n\nVeuillez autoriser l\'accès à la caméra dans les paramètres de l\'application.',
                    buttonText: 'OK',
                  );
                }
              },
            );
          } else if (state is DeviceUnlockFailed) {
            AppDialogs.hide(context);
            // Show error dialog with Skip option
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Échec du Déverrouillage'),
                  ],
                ),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      // Skip unlock and go directly to QR scanner
                      final permissionService = CameraPermissionService();
                      final hasPermission = await permissionService.ensureCameraPermission();

                      if (hasPermission && context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AccessBloc>(),
                              child: const QRScannerScreen(),
                            ),
                          ),
                        );
                      } else if (context.mounted) {
                        AppDialogs.showError(
                          context: context,
                          title: 'Permission Requise',
                          message: 'L\'accès à la caméra est nécessaire pour scanner le QR code.',
                          buttonText: 'OK',
                        );
                      }
                    },
                    child: const Text('Ignorer et continuer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AccessBloc>().add(const DeviceUnlockRequested());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DeviceUnlockInProgress;
          final hasError = state is DeviceUnlockFailed;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                          (Scaffold.of(context).appBarMaxHeight ?? 56),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated lock icon with proper animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasError ? Icons.lock_outline : Icons.lock_open_outlined,
                            size: iconSize,
                            color: hasError ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing1),

                      // Title
                      Text(
                        'Déverrouillez votre téléphone',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isVerySmallHeight ? 12 : 16),

                      // Subtitle
                      Text(
                        'Utilisez votre méthode habituelle\n(empreinte, face, schéma, PIN, mot de passe)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: verticalSpacing2),

                      // Loading indicator
                      if (isLoading)
                        SizedBox(
                          width: loadingSize,
                          height: loadingSize,
                          child: CircularProgressIndicator(
                            strokeWidth: isSmallScreen ? 2.5 : 3,
                          ),
                        ),

                      // Skip button in dev mode (always visible)
                      if (!hasError && AppConstants.isDevelopmentMode) ...[
                        SizedBox(height: isVerySmallHeight ? 16 : 24),
                        TextButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Skip unlock in dev mode - go directly to QR scanner
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<AccessBloc>(),
                                        child: const QRScannerScreen(),
                                      ),
                                    ),
                                  );
                                },
                          icon: Icon(Icons.skip_next, size: isSmallScreen ? 18 : 20),
                          label: Text(
                            'Ignorer le déverrouillage (DEV)',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                          ),
                        ),
                        Text(
                          '⚠️ Mode Développement Actif',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: AppColors.warning,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      // Error state with retry button
                      if (hasError) ...[
                        SizedBox(height: isVerySmallHeight ? 16 : 24),

                        // Error title
                        Text(
                          'Échec du déverrouillage',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isVerySmallHeight ? 8 : 12),

                        // Error message (detailed)
                        if (state is DeviceUnlockFailed)
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              state.message,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(height: isVerySmallHeight ? 12 : 16),

                        // Retry button
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context.read<AccessBloc>().add(const DeviceUnlockRequested()),
                          icon: Icon(Icons.refresh, size: isSmallScreen ? 20 : 24),
                          label: Text(
                            'Réessayer',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24 : 32,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                        ),

                        // Skip button in development mode
                        if (AppConstants.isDevelopmentMode) ...[
                          SizedBox(height: isVerySmallHeight ? 8 : 12),
                          TextButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Skip unlock in dev mode - go directly to QR scanner
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<AccessBloc>(),
                                          child: const QRScannerScreen(),
                                        ),
                                      ),
                                    );
                                  },
                            icon: Icon(Icons.skip_next, size: isSmallScreen ? 18 : 20),
                            label: Text(
                              'Continuer sans déverrouillage (DEV)',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.warning,
                            ),
                          ),
                          SizedBox(height: isVerySmallHeight ? 4 : 8),
                          Text(
                            '⚠️ Mode Développement',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: AppColors.warning,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],

                      // Padding bottom for small screens
                      if (isVerySmallHeight) const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}