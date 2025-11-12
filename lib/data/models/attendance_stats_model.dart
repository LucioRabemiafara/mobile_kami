/// Attendance Statistics Model
///
/// Contains monthly attendance statistics for a user
class AttendanceStatsModel {
  final int userId;
  final String userFullName;
  final String startDate; // yyyy-MM-dd
  final String endDate; // yyyy-MM-dd
  final int totalDaysWorked;
  final double totalHoursWorked;
  final double averageHoursPerDay;
  final int totalLateArrivals;
  final String generatedAt;

  const AttendanceStatsModel({
    required this.userId,
    required this.userFullName,
    required this.startDate,
    required this.endDate,
    this.totalDaysWorked = 0,
    this.totalHoursWorked = 0.0,
    this.averageHoursPerDay = 0.0,
    this.totalLateArrivals = 0,
    required this.generatedAt,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      userId: json['userId'] as int,
      userFullName: json['userFullName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      totalDaysWorked: json['totalDaysWorked'] as int? ?? 0,
      totalHoursWorked: (json['totalHoursWorked'] as num?)?.toDouble() ?? 0.0,
      averageHoursPerDay: (json['averageHoursPerDay'] as num?)?.toDouble() ?? 0.0,
      totalLateArrivals: json['totalLateArrivals'] as int? ?? 0,
      generatedAt: json['generatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userFullName': userFullName,
      'startDate': startDate,
      'endDate': endDate,
      'totalDaysWorked': totalDaysWorked,
      'totalHoursWorked': totalHoursWorked,
      'averageHoursPerDay': averageHoursPerDay,
      'totalLateArrivals': totalLateArrivals,
      'generatedAt': generatedAt,
    };
  }

  @override
  String toString() {
    return 'AttendanceStatsModel(userId: $userId, userFullName: $userFullName, totalDaysWorked: $totalDaysWorked, totalHoursWorked: $totalHoursWorked, averageHoursPerDay: $averageHoursPerDay, totalLateArrivals: $totalLateArrivals)';
  }
}
