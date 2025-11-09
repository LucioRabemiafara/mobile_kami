import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

/// Get Today Attendance UseCase
///
/// Retrieves today's attendance record for a user.
/// Returns null if user hasn't checked in today.
@injectable
class GetTodayAttendanceUseCase {
  final AttendanceRepository _attendanceRepository;

  GetTodayAttendanceUseCase(this._attendanceRepository);

  /// Execute get today's attendance
  ///
  /// [userId] User ID (int)
  ///
  /// Returns Either<Failure, AttendanceModel?>
  /// Returns null if no attendance record for today
  Future<Either<Failure, AttendanceModel?>> call({
    required int userId,
  }) async {
    return await _attendanceRepository.getAttendanceToday(
      userId: userId,
    );
  }
}
