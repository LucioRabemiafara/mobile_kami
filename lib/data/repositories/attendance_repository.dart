import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/attendance_api.dart';
import '../models/attendance_model.dart';
import '../models/attendance_stats_model.dart';

/// Attendance Repository Interface
abstract class AttendanceRepository {
  /// Check in
  Future<Either<Failure, AttendanceModel>> checkIn({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkInTime,
    String? location,
  });

  /// Check out
  Future<Either<Failure, AttendanceModel>> checkOut({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkOutTime,
    String? location,
  });

  /// Get today's attendance
  Future<Either<Failure, AttendanceModel?>> getAttendanceToday({
    required int userId,
  });

  /// Get attendance history
  Future<Either<Failure, List<AttendanceModel>>> getAttendanceHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get monthly attendance statistics
  Future<Either<Failure, AttendanceStatsModel>> getAttendanceStats({
    required int userId,
    int? month,
    int? year,
  });
}

/// Attendance Repository Implementation
@LazySingleton(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceApi _attendanceApi;

  AttendanceRepositoryImpl(this._attendanceApi);

  @override
  Future<Either<Failure, AttendanceModel>> checkIn({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkInTime,
    String? location,
  }) async {
    try {
      final attendance = await _attendanceApi.checkIn(
        userId: userId,
        qrCode: qrCode,
        pinCode: pinCode,
        checkInTime: checkInTime,
        location: location,
      );

      return Right(attendance);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on InvalidPinException catch (e) {
      return Left(InvalidPinFailure(
        message: e.message,
        attemptsRemaining: e.attemptsRemaining,
      ));
    } on AccountLockedException catch (e) {
      return Left(AccountLockedFailure(
        message: e.message,
        lockedUntil: e.lockedUntil,
      ));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AttendanceModel>> checkOut({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkOutTime,
    String? location,
  }) async {
    try {
      final attendance = await _attendanceApi.checkOut(
        userId: userId,
        qrCode: qrCode,
        pinCode: pinCode,
        checkOutTime: checkOutTime,
        location: location,
      );

      return Right(attendance);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on InvalidPinException catch (e) {
      return Left(InvalidPinFailure(
        message: e.message,
        attemptsRemaining: e.attemptsRemaining,
      ));
    } on AccountLockedException catch (e) {
      return Left(AccountLockedFailure(
        message: e.message,
        lockedUntil: e.lockedUntil,
      ));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AttendanceModel?>> getAttendanceToday({
    required int userId,
  }) async {
    try {
      final attendance = await _attendanceApi.getAttendanceToday(userId: userId);

      return Right(attendance);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceModel>>> getAttendanceHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final attendances = await _attendanceApi.getAttendanceHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(attendances);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AttendanceStatsModel>> getAttendanceStats({
    required int userId,
    int? month,
    int? year,
  }) async {
    try {
      final stats = await _attendanceApi.getAttendanceStats(
        userId: userId,
        month: month,
        year: year,
      );

      return Right(stats);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }
}
