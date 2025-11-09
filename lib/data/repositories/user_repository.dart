import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/user_api.dart';
import '../models/user_model.dart';
import '../models/zone_model.dart';

/// User Repository Interface
abstract class UserRepository {
  /// Get user by ID
  Future<Either<Failure, UserModel>> getUser(int userId);

  /// Get zones accessible by user
  Future<Either<Failure, List<ZoneModel>>> getAccessZones(int userId);
}

/// User Repository Implementation
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;

  UserRepositoryImpl(this._userApi);

  @override
  Future<Either<Failure, UserModel>> getUser(int userId) async {
    try {
      final user = await _userApi.getUser(userId);

      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ZoneModel>>> getAccessZones(
    int userId,
  ) async {
    try {
      final zones = await _userApi.getAccessZones(userId);

      return Right(zones);
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
