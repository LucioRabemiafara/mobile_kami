import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';
import '../../widgets/access/pin_pad.dart';
import '../../widgets/common/app_dialogs.dart';
import 'access_granted_screen.dart';

/// Pin Entry Screen
///
/// Allows user to enter 4-digit PIN for high-security zones
/// 3 attempts max before account lock
class PinEntryScreen extends StatefulWidget {
  final String zoneName;
  final int eventId;

  const PinEntryScreen({
    super.key,
    required this.zoneName,
    required this.eventId,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
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
    context.read<AccessBloc>().add(
          PINSubmitted(
            eventId: widget.eventId,
            pinCode: pin,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code PIN'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Pop to first route (Dashboard)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is PINVerifying) {
            AppDialogs.showLoading(
              context: context,
              message: 'Vérification du code PIN...',
            );
          } else if (state is AccessGranted) {
            AppDialogs.hide(context);
            // PIN correct, access granted
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AccessGrantedScreen(zoneName: state.zoneName),
              ),
            );
          } else if (state is PINIncorrect) {
            AppDialogs.hide(context);
            // PIN incorrect, show error and clear
            AppDialogs.showError(
              context: context,
              title: 'Code Incorrect',
              message: 'Il vous reste ${state.attemptsRemaining} tentative${state.attemptsRemaining > 1 ? 's' : ''}.',
              buttonText: 'Réessayer',
            );

            // Clear PIN
            setState(() {
              pin = '';
            });
          } else if (state is AccountLocked) {
            AppDialogs.hide(context);
            // Account locked, show error dialog
            final now = DateTime.now();
            final duration = state.lockedUntil.difference(now);
            final minutes = duration.inMinutes;

            AppDialogs.showError(
              context: context,
              title: 'Compte Bloqué',
              message: 'Trop de tentatives incorrectes.\n\nVotre compte est bloqué pendant $minutes minute${minutes > 1 ? 's' : ''}.',
              buttonText: 'Retour',
              barrierDismissible: false,
              onConfirm: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          } else if (state is AccessError) {
            AppDialogs.hide(context);
            // Error occurred
            AppDialogs.showError(
              context: context,
              title: 'Erreur',
              message: state.message,
              buttonText: 'OK',
            );

            // Clear PIN
            setState(() {
              pin = '';
            });
          }
        },
        builder: (context, state) {
          final isVerifying = state is PINVerifying;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Zone name
                Text(
                  widget.zoneName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Security level chip
                Chip(
                  label: const Text(
                    'Sécurité Maximale',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),

                const SizedBox(height: 32),

                // Instructions
                Text(
                  'Entrez votre code PIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // PIN indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < pin.length
                            ? AppColors.primary
                            : AppColors.borderColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator or PIN pad
                if (isVerifying)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Vérification du code PIN...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                else
                  PinPad(
                    onNumberPressed: _onNumberPressed,
                    onBackspacePressed: _onBackspacePressed,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
