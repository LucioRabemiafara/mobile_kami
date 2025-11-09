import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/access_request_api.dart';
import '../models/access_request_model.dart';

/// Access Request Repository Interface
abstract class AccessRequestRepository {
  /// Get all access requests for a user
  Future<Either<Failure, List<AccessRequestModel>>> getMyRequests(int userId);

  /// Create a new access request
  Future<Either<Failure, AccessRequestModel>> createRequest({
    required int userId,
    required int zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  });
}

/// Access Request Repository Implementation
@LazySingleton(as: AccessRequestRepository)
class AccessRequestRepositoryImpl implements AccessRequestRepository {
  final AccessRequestApi _accessRequestApi;

  AccessRequestRepositoryImpl(this._accessRequestApi);

  @override
  Future<Either<Failure, List<AccessRequestModel>>> getMyRequests(
    int userId,
  ) async {
    try {
      final requests = await _accessRequestApi.getMyRequests(userId);

      return Right(requests);
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
  Future<Either<Failure, AccessRequestModel>> createRequest({
    required int userId,
    required int zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  }) async {
    try {
      final request = await _accessRequestApi.createRequest(
        userId: userId,
        zoneId: zoneId,
        startDate: startDate,
        endDate: endDate,
        justification: justification,
      );

      return Right(request);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        fieldErrors: e.fieldErrors,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }
}
