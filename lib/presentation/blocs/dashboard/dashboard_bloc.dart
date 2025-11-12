import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/dashboard_kpis_model.dart';
import '../../../data/models/attendance_stats_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/zone_model.dart';
import '../../../data/models/access_event_model.dart';
import '../../../domain/usecases/attendance/get_attendance_stats_usecase.dart';
import '../../../domain/usecases/attendance/get_today_attendance_usecase.dart';
import '../../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../../domain/usecases/user/get_access_zones_usecase.dart';
import '../../../domain/usecases/access/get_access_history_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard BLoC
///
/// Manages dashboard data loading and state by aggregating data from multiple sources
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAttendanceStatsUseCase _getAttendanceStatsUseCase;
  final GetTodayAttendanceUseCase _getTodayAttendanceUseCase;
  final GetAttendanceHistoryUseCase _getAttendanceHistoryUseCase;
  final GetAccessZonesUseCase _getAccessZonesUseCase;
  final GetAccessHistoryUseCase _getAccessHistoryUseCase;

  DashboardBloc({
    required GetAttendanceStatsUseCase getAttendanceStatsUseCase,
    required GetTodayAttendanceUseCase getTodayAttendanceUseCase,
    required GetAttendanceHistoryUseCase getAttendanceHistoryUseCase,
    required GetAccessZonesUseCase getAccessZonesUseCase,
    required GetAccessHistoryUseCase getAccessHistoryUseCase,
  })  : _getAttendanceStatsUseCase = getAttendanceStatsUseCase,
        _getTodayAttendanceUseCase = getTodayAttendanceUseCase,
        _getAttendanceHistoryUseCase = getAttendanceHistoryUseCase,
        _getAccessZonesUseCase = getAccessZonesUseCase,
        _getAccessHistoryUseCase = getAccessHistoryUseCase,
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
    await _loadDashboardData(event.userId, emit);
  }

  /// Handle dashboard refresh request
  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // For refresh, we don't emit loading state (pull-to-refresh handles UI)
    await _loadDashboardData(event.userId, emit);
  }

  /// Load dashboard data by aggregating data from multiple endpoints
  Future<void> _loadDashboardData(
    int userId,
    Emitter<DashboardState> emit,
  ) async {

    // Call all endpoints in parallel for better performance
    final results = await Future.wait([
      _getAttendanceStatsUseCase(userId: userId),           // 1. Monthly stats
      _getTodayAttendanceUseCase(userId: userId),            // 2. Today's attendance
      _getAttendanceHistoryUseCase(                          // 3. Last 7 days
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 6)),
        endDate: DateTime.now(),
      ),
      _getAccessZonesUseCase(userId: userId),                // 4. Accessible zones
      _getAccessHistoryUseCase(                              // 5. Today's accesses
        userId: userId,
        startDate: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
        endDate: DateTime.now(),
      ),
    ]);

    // Check if any request failed
    Failure? firstFailure;
    for (var result in results) {
      result.fold(
        (failure) {
          if (firstFailure == null) firstFailure = failure;
        },
        (_) {},
      );
    }

    // If any request failed, emit error
    if (firstFailure != null) {
      emit(DashboardError(_mapFailureToMessage(firstFailure!)));
      return;
    }

    // Extract data from results with proper type casting
    AttendanceStatsModel? attendanceStats;
    AttendanceModel? todayAttendance;
    List<AttendanceModel> last7DaysAttendances = [];
    List<ZoneModel> accessZones = [];
    List<AccessEventModel> todayAccesses = [];

    results[0].fold(
      (l) => null,
      (r) => attendanceStats = r as AttendanceStatsModel?,
    );
    results[1].fold(
      (l) => null,
      (r) => todayAttendance = r as AttendanceModel?,
    );
    results[2].fold(
      (l) => null,
      (r) => last7DaysAttendances = (r as List).cast<AttendanceModel>(),
    );
    results[3].fold(
      (l) => null,
      (r) => accessZones = (r as List).cast<ZoneModel>(),
    );
    results[4].fold(
      (l) => null,
      (r) => todayAccesses = (r as List).cast<AccessEventModel>(),
    );

    // Build last7DaysHours list
    final last7DaysHours = <DayHoursModel>[];
    for (var attendance in last7DaysAttendances) {
      // Convert DateTime to String format (yyyy-MM-dd)
      final dateString = attendance.date.toIso8601String().split('T')[0];
      last7DaysHours.add(DayHoursModel(
        date: dateString,
        hours: attendance.hoursWorked,
      ));
    }

    // Aggregate all data into DashboardKpisModel
    final kpis = DashboardKpisModel(
      hoursThisMonth: attendanceStats?.totalHoursWorked ?? 0.0,
      accessibleZones: accessZones.length,
      accessesToday: todayAccesses.length,
      checkedInToday: todayAttendance?.checkIn != null,
      last7DaysHours: last7DaysHours,
      averageHoursPerDay: attendanceStats?.averageHoursPerDay ?? 0.0,
      daysWorkedThisMonth: attendanceStats?.totalDaysWorked ?? 0,
      lateCount: attendanceStats?.totalLateArrivals ?? 0,
    );

    emit(DashboardLoaded(kpis));
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
