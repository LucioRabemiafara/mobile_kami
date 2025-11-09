import 'package:equatable/equatable.dart';

/// Access Events
///
/// Events for zone access control workflow
abstract class AccessEvent extends Equatable {
  const AccessEvent();

  @override
  List<Object?> get props => [];
}

/// Device Unlock Requested Event
///
/// Dispatched when user needs to unlock device before scanning QR
class DeviceUnlockRequested extends AccessEvent {
  const DeviceUnlockRequested();
}

/// QR Code Scanned Event
///
/// Dispatched when user scans a QR code for zone access
class QRCodeScanned extends AccessEvent {
  final String qrCode;

  const QRCodeScanned(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

/// PIN Submitted Event
///
/// Dispatched when user submits PIN for high-security zones
class PINSubmitted extends AccessEvent {
  final int eventId;
  final String pinCode;

  const PINSubmitted({
    required this.eventId,
    required this.pinCode,
  });

  @override
  List<Object?> get props => [eventId, pinCode];
}

/// Access Reset Event
///
/// Resets access flow to initial state
class AccessReset extends AccessEvent {
  const AccessReset();
}
