import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/dashboard_kpis_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

/// Get KPIs UseCase
///
/// Retrieves dashboard KPIs (Key Performance Indicators) for the authenticated user.
/// Includes: total accesses, today's hours, week hours, and daily hours chart data.
/// Note: User is identified by JWT token in Authorization header.
@injectable
class GetKpisUseCase {
  final DashboardRepository _dashboardRepository;

  GetKpisUseCase(this._dashboardRepository);

  /// Execute get KPIs
  ///
  /// Returns Either<Failure, DashboardKpisModel>
  Future<Either<Failure, DashboardKpisModel>> call() async {
    return await _dashboardRepository.getKpis();
  }
}
