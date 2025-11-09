/// Dashboard KPIs Model
///
/// Contains all KPIs for the dashboard screen
class DashboardKpisModel {
  /// Total hours worked this month
  final double hoursThisMonth;

  /// Number of zones accessible by user
  final int accessibleZones;

  /// Number of accesses today
  final int accessesToday;

  /// Whether user has checked in today
  final bool checkedInToday;

  /// Hours worked for the last 7 days
  /// List of objects: { date: "2024-07-15", hours: 9.25 }
  final List<DayHoursModel> last7DaysHours;

  // Additional stats
  final double averageHoursPerDay;
  final int daysWorkedThisMonth;
  final int lateCount;

  const DashboardKpisModel({
    this.hoursThisMonth = 0.0,
    this.accessibleZones = 0,
    this.accessesToday = 0,
    this.checkedInToday = false,
    this.last7DaysHours = const [],
    this.averageHoursPerDay = 0.0,
    this.daysWorkedThisMonth = 0,
    this.lateCount = 0,
  });

  factory DashboardKpisModel.fromJson(Map<String, dynamic> json) {
    return DashboardKpisModel(
      hoursThisMonth: (json['hoursThisMonth'] as num?)?.toDouble() ?? 0.0,
      accessibleZones: json['accessibleZones'] as int? ?? 0,
      accessesToday: json['accessesToday'] as int? ?? 0,
      checkedInToday: json['checkedInToday'] as bool? ?? false,
      last7DaysHours: (json['last7DaysHours'] as List<dynamic>?)
              ?.map((e) => DayHoursModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageHoursPerDay: (json['averageHoursPerDay'] as num?)?.toDouble() ?? 0.0,
      daysWorkedThisMonth: json['daysWorkedThisMonth'] as int? ?? 0,
      lateCount: json['lateCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hoursThisMonth': hoursThisMonth,
      'accessibleZones': accessibleZones,
      'accessesToday': accessesToday,
      'checkedInToday': checkedInToday,
      'last7DaysHours': last7DaysHours.map((e) => e.toJson()).toList(),
      'averageHoursPerDay': averageHoursPerDay,
      'daysWorkedThisMonth': daysWorkedThisMonth,
      'lateCount': lateCount,
    };
  }

  DashboardKpisModel copyWith({
    double? hoursThisMonth,
    int? accessibleZones,
    int? accessesToday,
    bool? checkedInToday,
    List<DayHoursModel>? last7DaysHours,
    double? averageHoursPerDay,
    int? daysWorkedThisMonth,
    int? lateCount,
  }) {
    return DashboardKpisModel(
      hoursThisMonth: hoursThisMonth ?? this.hoursThisMonth,
      accessibleZones: accessibleZones ?? this.accessibleZones,
      accessesToday: accessesToday ?? this.accessesToday,
      checkedInToday: checkedInToday ?? this.checkedInToday,
      last7DaysHours: last7DaysHours ?? this.last7DaysHours,
      averageHoursPerDay: averageHoursPerDay ?? this.averageHoursPerDay,
      daysWorkedThisMonth: daysWorkedThisMonth ?? this.daysWorkedThisMonth,
      lateCount: lateCount ?? this.lateCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardKpisModel &&
        other.hoursThisMonth == hoursThisMonth &&
        other.accessibleZones == accessibleZones &&
        other.accessesToday == accessesToday &&
        other.checkedInToday == checkedInToday &&
        _listEquals(other.last7DaysHours, last7DaysHours) &&
        other.averageHoursPerDay == averageHoursPerDay &&
        other.daysWorkedThisMonth == daysWorkedThisMonth &&
        other.lateCount == lateCount;
  }

  @override
  int get hashCode {
    return hoursThisMonth.hashCode ^
        accessibleZones.hashCode ^
        accessesToday.hashCode ^
        checkedInToday.hashCode ^
        last7DaysHours.hashCode ^
        averageHoursPerDay.hashCode ^
        daysWorkedThisMonth.hashCode ^
        lateCount.hashCode;
  }

  @override
  String toString() {
    return 'DashboardKpisModel(hoursThisMonth: $hoursThisMonth, accessibleZones: $accessibleZones, accessesToday: $accessesToday, checkedInToday: $checkedInToday, last7DaysHours: $last7DaysHours, averageHoursPerDay: $averageHoursPerDay, daysWorkedThisMonth: $daysWorkedThisMonth, lateCount: $lateCount)';
  }

  /// Helper function to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Day Hours Model
///
/// Represents hours worked on a specific day
class DayHoursModel {
  final String date; // yyyy-MM-dd
  final double hours;

  const DayHoursModel({
    required this.date,
    this.hours = 0.0,
  });

  factory DayHoursModel.fromJson(Map<String, dynamic> json) {
    return DayHoursModel(
      date: json['date'] as String,
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hours': hours,
    };
  }

  DayHoursModel copyWith({
    String? date,
    double? hours,
  }) {
    return DayHoursModel(
      date: date ?? this.date,
      hours: hours ?? this.hours,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DayHoursModel && other.date == date && other.hours == hours;
  }

  @override
  int get hashCode {
    return date.hashCode ^ hours.hashCode;
  }

  @override
  String toString() {
    return 'DayHoursModel(date: $date, hours: $hours)';
  }
}
