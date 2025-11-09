import 'package:equatable/equatable.dart';

/// Dashboard Events
///
/// Events for dashboard screen data loading
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request dashboard data
///
/// Fetches KPIs and stats for the authenticated user (from JWT token)
class DashboardDataRequested extends DashboardEvent {
  const DashboardDataRequested();
}

/// Event to refresh dashboard data
///
/// Used for pull-to-refresh functionality
class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
