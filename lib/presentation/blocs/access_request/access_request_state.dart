import 'package:equatable/equatable.dart';
import '../../../data/models/access_request_model.dart';
import '../../../data/models/zone_model.dart';

/// Access Request States
abstract class AccessRequestState extends Equatable {
  const AccessRequestState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class AccessRequestInitial extends AccessRequestState {
  const AccessRequestInitial();
}

/// Loading State (fetching requests)
class AccessRequestsLoading extends AccessRequestState {
  const AccessRequestsLoading();
}

/// Requests Loaded Successfully
class AccessRequestsLoaded extends AccessRequestState {
  final List<AccessRequestModel> requests;
  final List<AccessRequestModel> pendingRequests;
  final List<AccessRequestModel> approvedRequests;
  final List<AccessRequestModel> rejectedRequests;

  const AccessRequestsLoaded({
    required this.requests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
  });

  @override
  List<Object?> get props => [requests, pendingRequests, approvedRequests, rejectedRequests];
}

/// Creating Request State
class CreatingAccessRequest extends AccessRequestState {
  const CreatingAccessRequest();
}

/// Request Created Successfully
class AccessRequestCreated extends AccessRequestState {
  final AccessRequestModel request;

  const AccessRequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

/// Error State
class AccessRequestError extends AccessRequestState {
  final String message;

  const AccessRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading Zones State
class ZonesLoading extends AccessRequestState {
  const ZonesLoading();
}

/// Zones Loaded Successfully
class ZonesLoaded extends AccessRequestState {
  final List<ZoneModel> zones;

  const ZonesLoaded(this.zones);

  @override
  List<Object?> get props => [zones];
}

/// Zones Error State
class ZonesError extends AccessRequestState {
  final String message;

  const ZonesError(this.message);

  @override
  List<Object?> get props => [message];
}
