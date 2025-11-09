import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/dashboard/get_kpis_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard BLoC
///
/// Manages dashboard data loading and state
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKpisUseCase _getKpisUseCase;

  DashboardBloc({
    required GetKpisUseCase getKpisUseCase,
  })  : _getKpisUseCase = getKpisUseCase,
        super(const DashboardInitial()) {
    on<DashboardDataRequested>(_onDashboardDataRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
  }

  /// Handle dashboard data request
  Future<void> _onDashboardDataRequested(
    DashboardDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit);
  }

  /// Handle dashboard refresh request
  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // For refresh, we don't emit loading state (pull-to-refresh handles UI)
    await _loadDashboardData(emit);
  }

  /// Load dashboard data
  /// User is identified from JWT token in Authorization header
  Future<void> _loadDashboardData(
    Emitter<DashboardState> emit,
  ) async {
    final result = await _getKpisUseCase();

    result.fold(
      (failure) => emit(DashboardError(_mapFailureToMessage(failure))),
      (kpis) => emit(DashboardLoaded(kpis)),
    );
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Pas de connexion internet. Veuillez vérifier votre connexion.';
    } else if (failure is UnauthorizedFailure) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else {
      return 'Une erreur inattendue s\'est produite.';
    }
  }
}
