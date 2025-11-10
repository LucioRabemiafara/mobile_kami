import 'package:equatable/equatable.dart';
import '../../../data/models/access_event_model.dart';

/// Access States
///
/// Represents different states in the zone access workflow
abstract class AccessState extends Equatable {
  const AccessState();

  @override
  List<Object?> get props => [];
}

/// Initial State
///
/// Access flow hasn't started yet
class AccessInitial extends AccessState {
  const AccessInitial();
}

/// Device Unlock In Progress State
///
/// Device authentication is being requested
class DeviceUnlockInProgress extends AccessState {
  const DeviceUnlockInProgress();
}

/// Device Unlock Success State
///
/// Device was successfully unlocked
class DeviceUnlockSuccess extends AccessState {
  const DeviceUnlockSuccess();
}

/// Device Unlock Failure State
///
/// Device unlock failed
class DeviceUnlockFailed extends AccessState {
  final String message;

  const DeviceUnlockFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Access Verifying State
///
/// Verifying zone access with backend
class AccessVerifying extends AccessState {
  const AccessVerifying();
}

/// Access Granted State
///
/// User has been granted access to the zone
class AccessGranted extends AccessState {
  final String zoneName;

  const AccessGranted(this.zoneName);

  @override
  List<Object?> get props => [zoneName];
}

/// Access Pending PIN State
///
/// Zone requires PIN, waiting for user to enter it
class AccessPendingPIN extends AccessState {
  final String zoneName;
  final int eventId;

  const AccessPendingPIN({
    required this.zoneName,
    required this.eventId,
  });

  @override
  List<Object?> get props => [zoneName, eventId];
}

/// Access Denied State
///
/// User was denied access to the zone
class AccessDenied extends AccessState {
  final String zoneName;
  final String reason;

  const AccessDenied({
    required this.zoneName,
    required this.reason,
  });

  @override
  List<Object?> get props => [zoneName, reason];
}

/// PIN Verifying State
///
/// Verifying PIN code with backend
class PINVerifying extends AccessState {
  const PINVerifying();
}

/// PIN Incorrect State
///
/// PIN was incorrect, user has more attempts
class PINIncorrect extends AccessState {
  final int attemptsRemaining;

  const PINIncorrect(this.attemptsRemaining);

  @override
  List<Object?> get props => [attemptsRemaining];
}

/// Account Locked State
///
/// Account is locked due to too many failed PIN attempts
class AccountLocked extends AccessState {
  final DateTime lockedUntil;

  const AccountLocked(this.lockedUntil);

  @override
  List<Object?> get props => [lockedUntil];
}

/// Access Error State
///
/// An error occurred during access verification
class AccessError extends AccessState {
  final String message;

  const AccessError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Access History Loading State
///
/// History is being loaded from the server
class AccessHistoryLoading extends AccessState {
  const AccessHistoryLoading();
}

/// Access History Loaded State
///
/// History has been successfully loaded
class AccessHistoryLoaded extends AccessState {
  final List<AccessEventModel> events;

  const AccessHistoryLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

/// Access History Error State
///
/// An error occurred while loading history
class AccessHistoryError extends AccessState {
  final String message;

  const AccessHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
