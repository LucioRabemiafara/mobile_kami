import 'package:equatable/equatable.dart';

/// Access Request Events
abstract class AccessRequestEvent extends Equatable {
  const AccessRequestEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Fetch User's Access Requests
class MyRequestsRequested extends AccessRequestEvent {
  final int userId;

  const MyRequestsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event: Create New Access Request
class CreateRequestSubmitted extends AccessRequestEvent {
  final int userId;
  final int zoneId;
  final DateTime startDate;
  final DateTime endDate;
  final String justification;

  const CreateRequestSubmitted({
    required this.userId,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.justification,
  });

  @override
  List<Object?> get props => [userId, zoneId, startDate, endDate, justification];
}

/// Event: Reset Access Request State
class AccessRequestReset extends AccessRequestEvent {
  const AccessRequestReset();
}

/// Event: Fetch All Zones
class ZonesRequested extends AccessRequestEvent {
  const ZonesRequested();
}
