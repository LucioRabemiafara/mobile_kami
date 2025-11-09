import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_kpis_model.dart';

/// Dashboard States
///
/// States for dashboard screen data
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading dashboard data
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Dashboard data loaded successfully
class DashboardLoaded extends DashboardState {
  final DashboardKpisModel kpis;

  const DashboardLoaded(this.kpis);

  @override
  List<Object?> get props => [kpis];
}

/// Error loading dashboard data
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
