import 'package:equatable/equatable.dart';

/// Access Request Entity
///
/// Pure business object representing a temporary access request
class AccessRequest extends Equatable {
  final String id;
  final String userId;
  final String zoneId;
  final DateTime startDate;
  final DateTime endDate;
  final String justification;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;

  const AccessRequest({
    required this.id,
    required this.userId,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.justification,
    required this.status,
    this.adminNote,
    this.createdAt,
  });

  /// Check if request is pending
  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Check if request is approved
  bool get isApproved => status.toUpperCase() == 'APPROVED';

  /// Check if request is rejected
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  /// Check if access period is currently active
  bool isActiveNow() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get number of days requested
  int get daysRequested => endDate.difference(startDate).inDays;

  @override
  List<Object?> get props => [
        id,
        userId,
        zoneId,
        startDate,
        endDate,
        justification,
        status,
        adminNote,
        createdAt,
      ];
}
