import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

/// Check Out UseCase
///
/// Records employee check-out (departure) from work.
/// Requires QR code scan and PIN code.
@injectable
class CheckOutUseCase {
  final AttendanceRepository _attendanceRepository;

  CheckOutUseCase(this._attendanceRepository);

  /// Execute check-out
  ///
  /// [userId] User ID (int)
  /// [qrCode] Scanned QR code
  /// [pinCode] User's PIN code
  /// [checkOutTime] Check-out timestamp
  /// [location] Location information (optional)
  ///
  /// Returns Either<Failure, AttendanceModel>
  Future<Either<Failure, AttendanceModel>> call({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkOutTime,
    String? location,
  }) async {
    return await _attendanceRepository.checkOut(
      userId: userId,
      qrCode: qrCode,
      pinCode: pinCode,
      checkOutTime: checkOutTime,
      location: location,
    );
  }
}
