import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

/// Authentication States
///
/// Represents different authentication states of the app
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial State
///
/// App just started, authentication status unknown
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading State
///
/// Authentication operation in progress (login, logout, token check)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated State
///
/// User is successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated State
///
/// User is not authenticated, needs to login
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error State
///
/// Authentication error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
