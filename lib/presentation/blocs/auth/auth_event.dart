import 'package:equatable/equatable.dart';

/// Authentication Events
///
/// Events that trigger authentication state changes
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App Started Event
///
/// Dispatched when app starts to check if user is already authenticated
/// Checks for existing token in storage
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Login Requested Event
///
/// Dispatched when user attempts to login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];

}

/// Logout Requested Event
///
/// Dispatched when user wants to logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
