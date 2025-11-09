import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../access_requests/create_access_request_screen.dart';

/// Access Denied Screen
///
/// Error screen showing zone access has been denied
/// Shows reason
class AccessDeniedScreen extends StatefulWidget {
  final String zoneName;
  final String reason;

  const AccessDeniedScreen({
    super.key,
    required this.zoneName,
    required this.reason,
  });

  @override
  State<AccessDeniedScreen> createState() => _AccessDeniedScreenState();
}

class _AccessDeniedScreenState extends State<AccessDeniedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Shake animation for error icon
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.05, 0.0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.05, 0.0),
          end: const Offset(0.05, 0.0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.05, 0.0),
          end: const Offset(-0.03, 0.0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.03, 0.0),
          end: const Offset(0.03, 0.0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.03, 0.0),
          end: Offset.zero,
        ),
        weight: 1,
      ),
    ]).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.error.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated error icon
                SlideTransition(
                  position: _shakeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cancel,
                      size: 80,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Accès Refusé',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Zone name
                Text(
                  widget.zoneName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Reason card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Raison du refus',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.reason,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Request access button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to CreateAccessRequestScreen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateAccessRequestScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Demander un Accès Temporaire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Return button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    child: const Text(
                      'Retour Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
