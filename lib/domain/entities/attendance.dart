import 'package:equatable/equatable.dart';

/// Attendance Entity
///
/// Pure business object representing a day's attendance
class Attendance extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double hoursWorked;
  final bool isLate;
  final DateTime? createdAt;

  const Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.hoursWorked,
    required this.isLate,
    this.createdAt,
  });

  /// Check if user has checked in
  bool get hasCheckedIn => checkIn != null;

  /// Check if user has checked out
  bool get hasCheckedOut => checkOut != null;

  /// Check if attendance is complete (both check-in and check-out)
  bool get isComplete => hasCheckedIn && hasCheckedOut;

  /// Get hours worked as formatted string (e.g., "9h 15m")
  String get hoursWorkedFormatted {
    final hours = hoursWorked.floor();
    final minutes = ((hoursWorked - hours) * 60).round();
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        checkIn,
        checkOut,
        hoursWorked,
        isLate,
        createdAt,
      ];
}
