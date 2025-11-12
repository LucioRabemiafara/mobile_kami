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
/// Fetches KPIs and stats for the authenticated user
class DashboardDataRequested extends DashboardEvent {
  final int userId;

  const DashboardDataRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh dashboard data
///
/// Used for pull-to-refresh functionality
class DashboardRefreshRequested extends DashboardEvent {
  final int userId;

  const DashboardRefreshRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
