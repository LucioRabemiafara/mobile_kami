import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/remote/dashboard_api.dart';
import '../models/dashboard_kpis_model.dart';

/// Dashboard Repository Interface
abstract class DashboardRepository {
  /// Get KPIs for dashboard
  Future<Either<Failure, DashboardKpisModel>> getKpis();
}

/// Dashboard Repository Implementation
@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApi _dashboardApi;

  DashboardRepositoryImpl(this._dashboardApi);

  @override
  Future<Either<Failure, DashboardKpisModel>> getKpis() async {
    try {
      final kpis = await _dashboardApi.getKpis();

      return Right(kpis);
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
