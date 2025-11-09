import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_cached_user_usecase.dart';
import '../../../domain/usecases/auth/is_authenticated_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
///
/// Manages authentication state throughout the app
/// Handles login, logout, and authentication status checks
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCachedUserUseCase _getCachedUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCachedUserUseCase getCachedUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCachedUserUseCase = getCachedUserUseCase,
        _isAuthenticatedUseCase = isAuthenticatedUseCase,
        super(const AuthInitial()) {
    // Register event handlers
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handle App Started Event
  ///
  /// Checks if user has valid token and cached user data
  /// Navigates to Dashboard if authenticated, Login otherwise
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Check if user is authenticated (has valid token)
    final isAuthenticated = await _isAuthenticatedUseCase();

    if (!isAuthenticated) {
      emit(const AuthUnauthenticated());
      return;
    }

    // User has token, get cached user data
    final result = await _getCachedUserUseCase();

    result.fold(
      (failure) {
        // Failed to get cached user, logout
        emit(const AuthUnauthenticated());
      },
      (user) {
        if (user != null) {
          // User found in cache
          emit(AuthAuthenticated(user));
        } else {
          // No cached user, logout
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Handle Login Requested Event
  ///
  /// Attempts to login with email and password
  /// Stores tokens and user data on success
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        // Login failed, emit error with user-friendly message
        print("Login Failed");
        final errorMessage = _mapFailureToMessage(failure);
        emit(AuthError(errorMessage));

        // After showing error, go back to unauthenticated state
        emit(const AuthUnauthenticated());
      },
      (user) {
        // Login successful, user data and tokens are already stored by repository
        print("Login Succes");
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Handle Logout Requested Event
  ///
  /// Clears tokens and user data from storage
  /// Calls backend logout endpoint
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Call logout use case (clears storage and calls API)
    await _logoutUseCase();

    // Always emit unauthenticated after logout
    emit(const AuthUnauthenticated());
  }

  /// Map Failure to User-Friendly Message
  ///
  /// Converts technical failures to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Email ou mot de passe incorrect';
    } else if (failure is AccountLockedFailure) {
      final accountLockedFailure = failure;
      if (accountLockedFailure.lockedUntil != null) {
        final lockedUntil = accountLockedFailure.lockedUntil!;
        final now = DateTime.now();

        if (lockedUntil.isAfter(now)) {
          final duration = lockedUntil.difference(now);
          final minutes = duration.inMinutes;

          if (minutes > 60) {
            final hours = (minutes / 60).ceil();
            return 'Compte bloqué pendant $hours heure${hours > 1 ? 's' : ''}';
          } else {
            return 'Compte bloqué pendant $minutes minute${minutes > 1 ? 's' : ''}';
          }
        } else {
          return 'Compte bloqué temporairement. Réessayez.';
        }
      }
      return 'Compte bloqué. Contactez l\'administrateur.';
    } else if (failure is ForbiddenFailure) {
      return 'Compte inactif. Contactez l\'administrateur.';
    } else if (failure is NetworkFailure) {
      return 'Pas de connexion internet';
    } else if (failure is TimeoutFailure) {
      return 'Délai d\'attente dépassé. Réessayez.';
    } else if (failure is ServerFailure) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else {
      return failure.message ?? 'Une erreur est survenue';
    }
  }
}
