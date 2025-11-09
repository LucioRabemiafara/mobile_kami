import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

/// Check In UseCase
///
/// Records employee check-in (arrival) at work.
/// Requires QR code scan and PIN code.
@injectable
class CheckInUseCase {
  final AttendanceRepository _attendanceRepository;

  CheckInUseCase(this._attendanceRepository);

  /// Execute check-in
  ///
  /// [userId] User ID (int)
  /// [qrCode] Scanned QR code
  /// [pinCode] User's PIN code
  /// [checkInTime] Check-in timestamp
  /// [location] Location information (optional)
  ///
  /// Returns Either<Failure, AttendanceModel>
  Future<Either<Failure, AttendanceModel>> call({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkInTime,
    String? location,
  }) async {
    return await _attendanceRepository.checkIn(
      userId: userId,
      qrCode: qrCode,
      pinCode: pinCode,
      checkInTime: checkInTime,
      location: location,
    );
  }
}
