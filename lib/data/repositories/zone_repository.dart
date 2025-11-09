import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/zone_api.dart';
import '../models/zone_model.dart';

/// Zone Repository Interface
abstract class ZoneRepository {
  /// Get all zones
  Future<Either<Failure, List<ZoneModel>>> getAllZones();
}

/// Zone Repository Implementation
@LazySingleton(as: ZoneRepository)
class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneApi _zoneApi;

  ZoneRepositoryImpl(this._zoneApi);

  @override
  Future<Either<Failure, List<ZoneModel>>> getAllZones() async {
    try {
      final zones = await _zoneApi.getAllZones();
      return Right(zones);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Erreur: ${e.toString()}'));
    }
  }
}
