import 'package:equatable/equatable.dart';

/// Dashboard KPIs Entity
///
/// Pure business object representing dashboard statistics
class DashboardKpis extends Equatable {
  final double hoursThisMonth;
  final int accessibleZones;
  final int accessesToday;
  final bool checkedInToday;
  final List<DayHours> last7DaysHours;

  const DashboardKpis({
    required this.hoursThisMonth,
    required this.accessibleZones,
    required this.accessesToday,
    required this.checkedInToday,
    required this.last7DaysHours,
  });

  /// Get hours worked yesterday
  double get yesterdayHours {
    if (last7DaysHours.length < 2) return 0.0;
    return last7DaysHours[last7DaysHours.length - 2].hours;
  }

  /// Get hours worked today
  double get todayHours {
    if (last7DaysHours.isEmpty) return 0.0;
    return last7DaysHours.last.hours;
  }

  @override
  List<Object?> get props => [
        hoursThisMonth,
        accessibleZones,
        accessesToday,
        checkedInToday,
        last7DaysHours,
      ];
}

/// Day Hours
///
/// Represents hours worked on a specific day
class DayHours extends Equatable {
  final String date; // yyyy-MM-dd
  final double hours;

  const DayHours({
    required this.date,
    required this.hours,
  });

  @override
  List<Object?> get props => [date, hours];
}
