import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/attendance_stats_model.dart';
import '../../../data/repositories/attendance_repository.dart';

/// Get Attendance Stats UseCase
///
/// Retrieves monthly attendance statistics for a user.
/// Includes: total days worked, total hours worked, average hours per day, late arrivals.
@injectable
class GetAttendanceStatsUseCase {
  final AttendanceRepository _attendanceRepository;

  GetAttendanceStatsUseCase(this._attendanceRepository);

  /// Execute get attendance stats
  ///
  /// [userId] - User ID
  /// [month] - Month (1-12, optional, default: current month)
  /// [year] - Year (optional, default: current year)
  ///
  /// Returns Either<Failure, AttendanceStatsModel>
  Future<Either<Failure, AttendanceStatsModel>> call({
    required int userId,
    int? month,
    int? year,
  }) async {
    return await _attendanceRepository.getAttendanceStats(
      userId: userId,
      month: month,
      year: year,
    );
  }
}
