import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../widgets/access/pin_pad.dart';
import '../../widgets/common/app_dialogs.dart';

/// Attendance PIN Entry Screen
///
/// Allows user to enter 4-digit PIN for attendance check-in/check-out
class AttendancePinEntryScreen extends StatefulWidget {
  final String qrCode;
  final bool isCheckIn;

  const AttendancePinEntryScreen({
    super.key,
    required this.qrCode,
    required this.isCheckIn,
  });

  @override
  State<AttendancePinEntryScreen> createState() =>
      _AttendancePinEntryScreenState();
}

class _AttendancePinEntryScreenState extends State<AttendancePinEntryScreen> {
  String pin = '';

  void _onNumberPressed(String number) {
    if (pin.length < 4) {
      setState(() {
        pin += number;
      });

      // Auto-submit when 4 digits entered
      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && pin.length == 4) {
            _submitPin();
          }
        });
      }
    }
  }

  void _onBackspacePressed() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  void _submitPin() {
    // Send event with the actual PIN
    if (widget.isCheckIn) {
      context.read<AttendanceBloc>().add(
            CheckInPINSubmitted(
              qrCode: widget.qrCode,
              pinCode: pin,
            ),
          );
    } else {
      context.read<AttendanceBloc>().add(
            CheckOutPINSubmitted(
              qrCode: widget.qrCode,
              pinCode: pin,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCheckIn ? 'Pointage Entrée' : 'Pointage Sortie'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Pop to first route (Dashboard)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is CheckInVerifying || state is CheckOutVerifying) {
            AppDialogs.showLoading(
              context: context,
              message: 'Vérification du code PIN...',
            );
          } else if (state is CheckInSuccess || state is CheckOutSuccess) {
            AppDialogs.hide(context);
            // Success handled by attendance screen
            Navigator.of(context).pop();
          } else if (state is AttendanceError) {
            AppDialogs.hide(context);
            // Show error and clear PIN
            AppDialogs.showError(
              context: context,
              title: 'Code Incorrect',
              message: state.message,
              buttonText: 'Réessayer',
              onConfirm: () {
                setState(() {
                  pin = '';
                });
              },
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.isCheckIn
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isCheckIn ? Icons.login : Icons.logout,
                    size: 40,
                    color: widget.isCheckIn
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  widget.isCheckIn
                      ? 'Pointer votre entrée'
                      : 'Pointer votre sortie',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                const Text(
                  'Entrez votre code PIN à 4 chiffres',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // PIN indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 48),

                // PIN pad
                PinPad(
                  onNumberPressed: _onNumberPressed,
                  onBackspacePressed: _onBackspacePressed,
                ),

                const SizedBox(height: 32),

                // Help text
                const Text(
                  'Attention : 3 tentatives maximum\navant blocage du compte',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
