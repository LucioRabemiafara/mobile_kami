import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

/// Get Attendance History UseCase
///
/// Retrieves attendance history for a user for a date range.
@injectable
class GetAttendanceHistoryUseCase {
  final AttendanceRepository _attendanceRepository;

  GetAttendanceHistoryUseCase(this._attendanceRepository);

  /// Execute get attendance history
  ///
  /// [userId] User ID (int)
  /// [startDate] Start date (optional)
  /// [endDate] End date (optional)
  ///
  /// Returns Either<Failure, List<AttendanceModel>>
  Future<Either<Failure, List<AttendanceModel>>> call({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _attendanceRepository.getAttendanceHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
