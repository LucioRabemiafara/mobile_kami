import 'package:equatable/equatable.dart';

/// Attendance Events
///
/// Events for attendance (check-in/check-out) workflow
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request today's attendance status
///
/// Fetches current attendance status for the user
class TodayAttendanceRequested extends AttendanceEvent {
  final int userId;

  const TodayAttendanceRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to initiate device unlock for check-in
///
/// Starts the device unlock process before check-in
class CheckInUnlockRequested extends AttendanceEvent {
  const CheckInUnlockRequested();
}

/// Event to scan QR code for check-in
///
/// After device unlock, scan QR code to check in
class CheckInQRScanned extends AttendanceEvent {
  final String qrCode;

  const CheckInQRScanned(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

/// Event to initiate device unlock for check-out
///
/// Starts the device unlock process before check-out
class CheckOutUnlockRequested extends AttendanceEvent {
  const CheckOutUnlockRequested();
}

/// Event to scan QR code for check-out
///
/// After device unlock, scan QR code to check out
class CheckOutQRScanned extends AttendanceEvent {
  final String qrCode;

  const CheckOutQRScanned(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

/// Event to reset attendance state
///
/// Resets state back to initial or loaded state
class AttendanceReset extends AttendanceEvent {
  const AttendanceReset();
}
