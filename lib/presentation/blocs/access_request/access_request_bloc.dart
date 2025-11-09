import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/access_request/create_request_usecase.dart';
import '../../../domain/usecases/access_request/get_my_requests_usecase.dart';
import '../../../domain/usecases/zone/get_all_zones_usecase.dart';
import 'access_request_event.dart';
import 'access_request_state.dart';

/// Access Request BLoC
///
/// Manages access request creation and retrieval
/// For users requesting temporary access to zones they don't have permission for
class AccessRequestBloc extends Bloc<AccessRequestEvent, AccessRequestState> {
  final GetMyRequestsUseCase _getMyRequestsUseCase;
  final CreateRequestUseCase _createRequestUseCase;
  final GetAllZonesUseCase _getAllZonesUseCase;

  AccessRequestBloc({
    required GetMyRequestsUseCase getMyRequestsUseCase,
    required CreateRequestUseCase createRequestUseCase,
    required GetAllZonesUseCase getAllZonesUseCase,
  })  : _getMyRequestsUseCase = getMyRequestsUseCase,
        _createRequestUseCase = createRequestUseCase,
        _getAllZonesUseCase = getAllZonesUseCase,
        super(const AccessRequestInitial()) {
    // Register event handlers
    on<MyRequestsRequested>(_onMyRequestsRequested);
    on<CreateRequestSubmitted>(_onCreateRequestSubmitted);
    on<AccessRequestReset>(_onAccessRequestReset);
    on<ZonesRequested>(_onZonesRequested);
  }

  /// Handle My Requests Requested Event
  ///
  /// Fetches all access requests for the current user
  Future<void> _onMyRequestsRequested(
    MyRequestsRequested event,
    Emitter<AccessRequestState> emit,
  ) async {
    emit(const AccessRequestsLoading());

    final result = await _getMyRequestsUseCase(userId: event.userId);

    result.fold(
      (failure) {
        final errorMessage = _mapFailureToMessage(failure);
        emit(AccessRequestError(errorMessage));
      },
      (requests) {
        // Separate requests by status
        final pendingRequests = requests
            .where((r) => r.status.toUpperCase() == 'PENDING')
            .toList();
        final approvedRequests = requests
            .where((r) => r.status.toUpperCase() == 'APPROVED')
            .toList();
        final rejectedRequests = requests
            .where((r) => r.status.toUpperCase() == 'REJECTED')
            .toList();

        emit(AccessRequestsLoaded(
          requests: requests,
          pendingRequests: pendingRequests,
          approvedRequests: approvedRequests,
          rejectedRequests: rejectedRequests,
        ));
      },
    );
  }

  /// Handle Create Request Submitted Event
  ///
  /// Creates a new access request for temporary zone access
  Future<void> _onCreateRequestSubmitted(
    CreateRequestSubmitted event,
    Emitter<AccessRequestState> emit,
  ) async {
    emit(const CreatingAccessRequest());

    final result = await _createRequestUseCase(
      userId: event.userId,
      zoneId: event.zoneId,
      startDate: event.startDate,
      endDate: event.endDate,
      justification: event.justification,
    );

    result.fold(
      (failure) {
        final errorMessage = _mapFailureToMessage(failure);
        emit(AccessRequestError(errorMessage));
      },
      (request) {
        emit(AccessRequestCreated(request));
      },
    );
  }

  /// Handle Access Request Reset Event
  ///
  /// Resets state to initial
  Future<void> _onAccessRequestReset(
    AccessRequestReset event,
    Emitter<AccessRequestState> emit,
  ) async {
    emit(const AccessRequestInitial());
  }

  /// Handle Zones Requested Event
  ///
  /// Fetches all zones from the system
  Future<void> _onZonesRequested(
    ZonesRequested event,
    Emitter<AccessRequestState> emit,
  ) async {
    print('🔄 AccessRequestBloc: ZonesRequested - fetching zones...');
    emit(const ZonesLoading());

    final result = await _getAllZonesUseCase();

    result.fold(
      (failure) {
        final errorMessage = _mapFailureToMessage(failure);
        print('❌ AccessRequestBloc: Zones fetch failed - $errorMessage');
        emit(ZonesError(errorMessage));
      },
      (zones) {
        print('✅ AccessRequestBloc: Zones loaded successfully - ${zones.length} zones');
        for (var zone in zones) {
          print('   📍 Zone: ${zone.name} (ID: ${zone.id})');
        }
        emit(ZonesLoaded(zones));
      },
    );
  }

  /// Map Failure to User-Friendly Message
  ///
  /// Converts technical failures to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      // Return field-specific errors if available
      if (failure.fieldErrors != null && failure.fieldErrors!.isNotEmpty) {
        return failure.fieldErrors!.values.first;
      }
      return failure.message ?? 'Données invalides';
    } else if (failure is UnauthorizedFailure) {
      return 'Session expirée. Reconnectez-vous.';
    } else if (failure is ForbiddenFailure) {
      return 'Accès interdit';
    } else if (failure is NetworkFailure) {
      return 'Pas de connexion internet';
    } else if (failure is TimeoutFailure) {
      return 'Délai d\'attente dépassé';
    } else if (failure is ServerFailure) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else {
      return failure.message ?? 'Une erreur est survenue';
    }
  }
}
