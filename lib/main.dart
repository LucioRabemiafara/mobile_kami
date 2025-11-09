import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'core/constants/colors.dart';
import 'core/constants/text_styles.dart';
import 'injection_container.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await di.configureDependencies();

  // await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de formatage pour le français
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - available throughout the app
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        // Dashboard BLoC - available throughout the app
        BlocProvider<DashboardBloc>(
          create: (_) => di.sl<DashboardBloc>(),
        ),
        // Note: AccessBloc is created locally in DeviceUnlockScreen
        // because it depends on AuthBloc instance
        // Other BLoCs will be added here when created
      ],
      child: MaterialApp(
        title: 'Access Control',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: ThemeData(
          // Color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
            surface: Colors.white,
            background: AppColors.scaffoldBackground,
          ),

          // Scaffold
          scaffoldBackgroundColor: AppColors.scaffoldBackground,

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
            iconTheme: IconThemeData(
              color: AppColors.textOnPrimary,
            ),
          ),

          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Card theme
          // cardTheme: CardTheme(
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // ),

//          ThemeData
          // ThemeData(
          //   cardTheme: CardThemeData(
          //     color: Colors.white,
          //     shadowColor: Colors.grey,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );

          // Button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),

          // Icon theme
          iconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 24,
          ),

          // Text theme
          textTheme: const TextTheme(
            displayLarge: AppTextStyles.heading1,
            displayMedium: AppTextStyles.heading2,
            displaySmall: AppTextStyles.heading3,
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            titleLarge: AppTextStyles.subtitle1,
            titleMedium: AppTextStyles.subtitle2,
            bodyLarge: AppTextStyles.body1,
            bodyMedium: AppTextStyles.body2,
            labelLarge: AppTextStyles.button,
            bodySmall: AppTextStyles.caption,
          ),

          // Progress indicator
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),

          // Divider theme
          dividerTheme: const DividerThemeData(
            color: AppColors.borderColor,
            thickness: 1,
            space: 16,
          ),

          // Material 3
          useMaterial3: true,
        ),

        // Home screen - Splash Screen
        home: const SplashScreen(),
      ),
    );
  }
}
