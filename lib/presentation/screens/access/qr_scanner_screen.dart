import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';
import '../../widgets/common/app_dialogs.dart';
import 'access_denied_screen.dart';
import 'access_granted_screen.dart';
import 'pin_entry_screen.dart';

/// QR Scanner Screen
///
/// Scans QR codes for zone access
/// Requires device to be unlocked first
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    print('🎥 QR Scanner initialized');

    // Start the scanner
    controller.start().then((_) {
      print('✅ Scanner started successfully');
    }).catchError((error) {
      print('❌ Scanner start error: $error');
    });
  }

  @override
  void dispose() {
    print('🎥 Disposing QR Scanner');
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    print('🔍 QR Scanner: _onDetect called');
    print('🔍 isScanning: $isScanning');

    if (!isScanning) {
      print('⚠️ Already processing a scan, ignoring...');
      return;
    }

    if (!mounted) {
      print('⚠️ Widget not mounted, ignoring...');
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    print('🔍 Barcodes found: ${barcodes.length}');

    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      print('🔍 QR Code value: $code');

      if (code != null && code.isNotEmpty) {
        // Disable scanning immediately
        setState(() {
          isScanning = false;
        });

        HapticFeedback.mediumImpact();
        print('✅ Sending QRCodeScanned event with code: $code');

        // Add event to BLoC
        context.read<AccessBloc>().add(QRCodeScanned(code));
      } else {
        print('⚠️ QR Code is null or empty');
      }
    } else {
      print('⚠️ No barcodes found in capture');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is AccessVerifying) {
            // Show loading dialog during verification
            AppDialogs.showLoading(
              context: context,
              message: 'Vérification de l\'accès...',
            );
          } else if (state is AccessGranted) {
            // Close loading dialog
            AppDialogs.hide(context);
            // Access granted, navigate to success screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AccessGrantedScreen(zoneName: state.zoneName),
              ),
            );
          } else if (state is AccessPendingPIN) {
            // Close loading dialog
            AppDialogs.hide(context);
            // PIN required for high-security zone
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccessBloc>(),
                  child: PinEntryScreen(
                    zoneName: state.zoneName,
                    eventId: state.eventId,
                  ),
                ),
              ),
            );
          } else if (state is AccessDenied) {
            // Close loading dialog
            AppDialogs.hide(context);
            // Access denied
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AccessDeniedScreen(
                  zoneName: state.zoneName,
                  reason: state.reason,
                ),
              ),
            );
          } else if (state is AccessError) {
            // Close loading dialog
            AppDialogs.hide(context);
            // Error occurred, show error dialog
            AppDialogs.showError(
              context: context,
              title: 'Erreur de Vérification',
              message: state.message,
              buttonText: 'Réessayer',
              onConfirm: () {
                // Re-enable scanning
                setState(() {
                  isScanning = true;
                });
              },
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Mobile Scanner
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
              ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      // Flash button
                      IconButton(
                        icon: Icon(
                          controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => controller.toggleTorch(),
                      ),
                    ],
                  ),
                ),
              ),

              // Scan area overlay
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Text overlay
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Scannez le QR code de la zone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
