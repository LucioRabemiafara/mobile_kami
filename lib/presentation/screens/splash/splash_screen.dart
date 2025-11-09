import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

/// Splash Screen
///
/// Initial screen shown when app starts
/// Checks authentication status and navigates accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Dispatch AppStarted event to check authentication
    context.read<AuthBloc>().add(const AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, navigate to Dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            ),
          );
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, navigate to Login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'Access Control',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Système de Gestion d\'Accès',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 60),

              // Loading Indicator
              const SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.5,
                ),
              ),

              const SizedBox(height: 20),

              // Loading Text
              Text(
                'Initialisation...',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
