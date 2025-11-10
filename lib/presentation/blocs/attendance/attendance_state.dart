import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';

/// Attendance States
///
/// States for attendance workflow
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

/// Loading today's attendance status
class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

/// Today's attendance loaded
///
/// Shows current status (not checked in, checked in, or day complete)
class AttendanceLoaded extends AttendanceState {
  final AttendanceModel? attendance;

  const AttendanceLoaded({this.attendance});

  @override
  List<Object?> get props => [attendance];

  /// Whether user has checked in today
  bool get isCheckedIn => attendance != null && attendance!.checkIn != null;

  /// Whether user has completed the day (checked out)
  bool get isDayComplete =>
      attendance != null &&
      attendance!.checkIn != null &&
      attendance!.checkOut != null;
}

/// Device unlock in progress for check-in
class CheckInUnlockInProgress extends AttendanceState {
  const CheckInUnlockInProgress();
}

/// Device unlock successful for check-in, ready to scan QR
class CheckInUnlockSuccess extends AttendanceState {
  const CheckInUnlockSuccess();
}

/// Device unlock failed for check-in
class CheckInUnlockFailure extends AttendanceState {
  final String message;

  const CheckInUnlockFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Check-in QR code scanned, ready for PIN entry
class CheckInQRScannedSuccess extends AttendanceState {
  final String qrCode;

  const CheckInQRScannedSuccess(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

/// Check-in QR code being verified
class CheckInVerifying extends AttendanceState {
  const CheckInVerifying();
}

/// Check-in successful
class CheckInSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckInSuccess(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

/// Device unlock in progress for check-out
class CheckOutUnlockInProgress extends AttendanceState {
  const CheckOutUnlockInProgress();
}

/// Device unlock successful for check-out, ready to scan QR
class CheckOutUnlockSuccess extends AttendanceState {
  const CheckOutUnlockSuccess();
}

/// Device unlock failed for check-out
class CheckOutUnlockFailure extends AttendanceState {
  final String message;

  const CheckOutUnlockFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Check-out QR code scanned, ready for PIN entry
class CheckOutQRScannedSuccess extends AttendanceState {
  final String qrCode;

  const CheckOutQRScannedSuccess(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

/// Check-out QR code being verified
class CheckOutVerifying extends AttendanceState {
  const CheckOutVerifying();
}

/// Check-out successful
class CheckOutSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckOutSuccess(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

/// Error occurred during attendance operation
class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
