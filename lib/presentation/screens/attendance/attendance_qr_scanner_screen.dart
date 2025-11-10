import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../widgets/common/app_dialogs.dart';
import 'attendance_pin_entry_screen.dart';

/// Attendance QR Scanner Screen
///
/// QR code scanner for check-in or check-out
class AttendanceQRScannerScreen extends StatefulWidget {
  final bool isCheckIn;

  const AttendanceQRScannerScreen({
    super.key,
    required this.isCheckIn,
  });

  @override
  State<AttendanceQRScannerScreen> createState() =>
      _AttendanceQRScannerScreenState();
}

class _AttendanceQRScannerScreenState extends State<AttendanceQRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    print('🔍 Attendance QR Scanner: _onDetect called');
    print('🔍 isScanning: $isScanning, isCheckIn: ${widget.isCheckIn}');

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
        print('✅ Sending ${widget.isCheckIn ? "CheckIn" : "CheckOut"}QRScanned event');

        // Add event to BLoC
        if (widget.isCheckIn) {
          context.read<AttendanceBloc>().add(CheckInQRScanned(code));
        } else {
          context.read<AttendanceBloc>().add(CheckOutQRScanned(code));
        }
      } else {
        print('⚠️ QR Code is null or empty');
      }
    } else {
      print('⚠️ No barcodes found in capture');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is CheckInQRScannedSuccess) {
            // QR scanned successfully, navigate to PIN entry
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AttendanceBloc>(),
                  child: AttendancePinEntryScreen(
                    qrCode: state.qrCode,
                    isCheckIn: true,
                  ),
                ),
              ),
            );
          } else if (state is CheckOutQRScannedSuccess) {
            // QR scanned successfully, navigate to PIN entry
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AttendanceBloc>(),
                  child: AttendancePinEntryScreen(
                    qrCode: state.qrCode,
                    isCheckIn: false,
                  ),
                ),
              ),
            );
          } else if (state is AttendanceError) {
            // Show error dialog
            AppDialogs.showError(
              context: context,
              title: 'Erreur de Pointage',
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

              // Scan area overlay
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.isCheckIn ? AppColors.primary : AppColors.secondary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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

                      // Flash toggle
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

              // Instructions
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
                    child: Text(
                      widget.isCheckIn
                          ? 'Scannez le QR code pour pointer l\'entrée'
                          : 'Scannez le QR code pour pointer la sortie',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
