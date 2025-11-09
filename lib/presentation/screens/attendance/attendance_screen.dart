import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/camera_permission_service.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_dialogs.dart';
import 'attendance_qr_scanner_screen.dart';

/// Attendance Screen
///
/// Screen for check-in and check-out with live timer
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<AttendanceBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(TodayAttendanceRequested(authState.user.id));
        }
        return bloc;
      },
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime checkIn) {
    _timer?.cancel();

    // Calculate initial elapsed time
    _elapsedTime = DateTime.now().difference(checkIn);

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = DateTime.now().difference(checkIn);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsedTime = Duration.zero;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) async {
          if (state is CheckInUnlockSuccess) {
            // Check camera permission before opening scanner
            final permissionService = CameraPermissionService();
            final hasPermission = await permissionService.ensureCameraPermission();

            if (hasPermission && context.mounted) {
              // Navigate to QR scanner for check-in
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AttendanceBloc>(),
                    child: const AttendanceQRScannerScreen(isCheckIn: true),
                  ),
                ),
              );
            } else if (context.mounted) {
              // Permission denied - show error
              AppDialogs.showError(
                context: context,
                title: 'Permission Requise',
                message: 'L\'accès à la caméra est nécessaire pour scanner le QR code de pointage.',
                buttonText: 'OK',
              );
            }
          } else if (state is CheckInUnlockFailure) {
            AppDialogs.showError(
              context: context,
              title: 'Échec du Déverrouillage',
              message: state.message,
              buttonText: 'Réessayer',
              onConfirm: () {
                context
                    .read<AttendanceBloc>()
                    .add(const CheckInUnlockRequested());
              },
            );
          } else if (state is CheckInSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: 'Pointage Réussi',
              message: 'Votre entrée a été enregistrée avec succès !',
              buttonText: 'OK',
            );

            // Start timer
            _startTimer(state.attendance.checkIn!);

            // Navigate back to attendance screen
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Reload attendance data
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context
                  .read<AttendanceBloc>()
                  .add(TodayAttendanceRequested(authState.user.id));
            }
          } else if (state is CheckOutUnlockSuccess) {
            // Check camera permission before opening scanner
            final permissionService = CameraPermissionService();
            final hasPermission = await permissionService.ensureCameraPermission();

            if (hasPermission && context.mounted) {
              // Navigate to QR scanner for check-out
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AttendanceBloc>(),
                    child: const AttendanceQRScannerScreen(isCheckIn: false),
                  ),
                ),
              );
            } else if (context.mounted) {
              // Permission denied - show error
              AppDialogs.showError(
                context: context,
                title: 'Permission Requise',
                message: 'L\'accès à la caméra est nécessaire pour scanner le QR code de pointage.',
                buttonText: 'OK',
              );
            }
          } else if (state is CheckOutUnlockFailure) {
            AppDialogs.showError(
              context: context,
              title: 'Échec du Déverrouillage',
              message: state.message,
              buttonText: 'Réessayer',
              onConfirm: () {
                context
                    .read<AttendanceBloc>()
                    .add(const CheckOutUnlockRequested());
              },
            );
          } else if (state is CheckOutSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: 'Pointage Réussi',
              message: 'Votre sortie a été enregistrée avec succès !',
              buttonText: 'Retour Dashboard',
              onConfirm: () {
                // Navigate back to dashboard
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );

            // Stop timer
            _stopTimer();
          } else if (state is AttendanceError) {
            AppDialogs.showError(
              context: context,
              title: 'Erreur',
              message: state.message,
              buttonText: 'OK',
            );
          } else if (state is AttendanceLoaded) {
            // Start timer if already checked in
            if (state.isCheckedIn && !state.isDayComplete) {
              _startTimer(state.attendance!.checkIn!);
            } else {
              _stopTimer();
            }
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceError) {
            return _buildErrorView(state.message);
          }

          if (state is AttendanceLoaded) {
            return _buildAttendanceView(state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return AppBar(title: const Text('Pointage'));
    }

    final user = authState.user;

    return AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pointage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            // MULTI-POSTES chips
            if (user.posts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: user.posts.take(2).map((post) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Chip(
                        label: Text(
                          _formatPostName(post),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<AttendanceBloc>()
                      .add(TodayAttendanceRequested(authState.user.id));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceView(AttendanceLoaded state) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date
          Text(
            dateFormatter.format(now),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Status based on state
          if (!state.isCheckedIn)
            _buildNotCheckedInView()
          else if (!state.isDayComplete)
            _buildCheckedInView(state)
          else
            _buildDayCompleteView(state),
        ],
      ),
    );
  }

  Widget _buildNotCheckedInView() {
    return Column(
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.login,
            size: 60,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        const Text(
          'Pas encore pointé',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Subtitle
        const Text(
          'Scannez le QR code pour pointer votre arrivée',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // Check-in button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              context
                  .read<AttendanceBloc>()
                  .add(const CheckInUnlockRequested());
            },
            icon: const Icon(Icons.fingerprint, size: 28),
            label: const Text(
              'Pointer Entrée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckedInView(AttendanceLoaded state) {
    final checkIn = state.attendance!.checkIn!;
    final timeFormatter = DateFormat('HH:mm');

    return Column(
      children: [
        // Icon with pulse animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.05),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          onEnd: () {
            // Trigger rebuild to continue animation
            if (mounted) setState(() {});
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              size: 60,
              color: AppColors.success,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Title
        const Text(
          'En cours',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Check-in time
        Text(
          'Arrivée à ${timeFormatter.format(checkIn)}',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Live timer
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Temps écoulé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(_elapsedTime),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Check-out button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              context
                  .read<AttendanceBloc>()
                  .add(const CheckOutUnlockRequested());
            },
            icon: const Icon(Icons.logout, size: 28),
            label: const Text(
              'Pointer Sortie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCompleteView(AttendanceLoaded state) {
    final checkIn = state.attendance!.checkIn!;
    final checkOutTime = state.attendance!.checkOut!;
    final timeFormatter = DateFormat('HH:mm');
    final hoursWorked = state.attendance!.hoursWorked;

    return Column(
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 60,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        const Text(
          'Journée terminée',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Summary card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Check-in
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.login, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Arrivée',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeFormatter.format(checkIn),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Check-out
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Départ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeFormatter.format(checkOutTime),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Total hours
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${hoursWorked.toStringAsFixed(2)}h',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Return to dashboard button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.home),
          label: const Text('Retour Dashboard'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPostName(String post) {
    switch (post.toUpperCase()) {
      case 'DEVELOPER':
        return 'DEV';
      case 'DEVOPS':
        return 'DEVOPS';
      case 'SECURITY_AGENT':
        return 'SECURITE';
      case 'MANAGER':
        return 'MANAGER';
      case 'HR':
        return 'RH';
      default:
        return post.length > 8 ? post.substring(0, 8) : post;
    }
  }
}
