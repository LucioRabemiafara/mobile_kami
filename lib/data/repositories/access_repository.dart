import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/access_api.dart';
import '../models/access_verify_response_model.dart';
import '../models/access_event_model.dart';

/// Access Repository Interface
abstract class AccessRepository {
  /// Verify access to a zone
  Future<Either<Failure, AccessVerifyResponseModel>> verifyAccess({
    required int userId,
    required String qrCode,
    String? deviceInfo,
    String? ipAddress,
  });

  /// Verify PIN for high security zones
  Future<Either<Failure, AccessVerifyResponseModel>> verifyPin({
    required int userId,
    required String pinCode,
    required int eventId,
  });

  /// Get access history
  Future<Either<Failure, List<AccessEventModel>>> getAccessHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Access Repository Implementation
@LazySingleton(as: AccessRepository)
class AccessRepositoryImpl implements AccessRepository {
  final AccessApi _accessApi;

  AccessRepositoryImpl(this._accessApi);

  @override
  Future<Either<Failure, AccessVerifyResponseModel>> verifyAccess({
    required int userId,
    required String qrCode,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      final response = await _accessApi.verifyAccess(
        userId: userId,
        qrCode: qrCode,
        deviceInfo: deviceInfo,
        ipAddress: ipAddress,
      );

      return Right(response);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on QRCodeException catch (e) {
      return Left(QRCodeFailure(message: e.message));
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
  Future<Either<Failure, AccessVerifyResponseModel>> verifyPin({
    required int userId,
    required String pinCode,
    required int eventId,
  }) async {
    try {
      final response = await _accessApi.verifyPin(
        userId: userId,
        pinCode: pinCode,
        eventId: eventId,
      );

      return Right(response);
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
  Future<Either<Failure, List<AccessEventModel>>> getAccessHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _accessApi.getAccessHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(events);
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
