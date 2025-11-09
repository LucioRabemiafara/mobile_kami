import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/device_unlock_service.dart';
import '../../../domain/usecases/attendance/check_in_usecase.dart';
import '../../../domain/usecases/attendance/check_out_usecase.dart';
import '../../../domain/usecases/attendance/get_today_attendance_usecase.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

/// Attendance BLoC
///
/// Manages attendance workflow (check-in/check-out) with device unlock
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayAttendanceUseCase _getTodayAttendanceUseCase;
  final CheckInUseCase _checkInUseCase;
  final CheckOutUseCase _checkOutUseCase;
  final DeviceUnlockService _deviceUnlockService;
  final AuthBloc _authBloc;

  AttendanceBloc({
    required GetTodayAttendanceUseCase getTodayAttendanceUseCase,
    required CheckInUseCase checkInUseCase,
    required CheckOutUseCase checkOutUseCase,
    required DeviceUnlockService deviceUnlockService,
    required AuthBloc authBloc,
  })  : _getTodayAttendanceUseCase = getTodayAttendanceUseCase,
        _checkInUseCase = checkInUseCase,
        _checkOutUseCase = checkOutUseCase,
        _deviceUnlockService = deviceUnlockService,
        _authBloc = authBloc,
        super(const AttendanceInitial()) {
    on<TodayAttendanceRequested>(_onTodayAttendanceRequested);
    on<CheckInUnlockRequested>(_onCheckInUnlockRequested);
    on<CheckInQRScanned>(_onCheckInQRScanned);
    on<CheckOutUnlockRequested>(_onCheckOutUnlockRequested);
    on<CheckOutQRScanned>(_onCheckOutQRScanned);
    on<AttendanceReset>(_onAttendanceReset);
  }

  /// Handle today's attendance request
  Future<void> _onTodayAttendanceRequested(
    TodayAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await _getTodayAttendanceUseCase(userId: event.userId);

    result.fold(
      (failure) {
        // If no attendance found, it's ok - user hasn't checked in yet
        if (failure is ServerFailure &&
            failure.message.toLowerCase().contains('not found')) {
          emit(const AttendanceLoaded(attendance: null));
        } else {
          emit(AttendanceError(_mapFailureToMessage(failure)));
        }
      },
      (attendance) => emit(AttendanceLoaded(attendance: attendance)),
    );
  }

  /// Handle check-in device unlock request
  Future<void> _onCheckInUnlockRequested(
    CheckInUnlockRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const CheckInUnlockInProgress());

    final canCheck = await _deviceUnlockService.canCheckDeviceUnlock();
    if (!canCheck) {
      emit(const CheckInUnlockFailure(
        'Le déverrouillage de l\'appareil n\'est pas disponible sur cet appareil',
      ));
      return;
    }

    // CRITICAL: biometricOnly: false accepts ALL methods
    final isAuthenticated = await _deviceUnlockService.authenticate(
      localizedReason: 'Déverrouillez votre appareil pour pointer',
    );

    if (isAuthenticated) {
      emit(const CheckInUnlockSuccess());
    } else {
      emit(const CheckInUnlockFailure(
        'Déverrouillage annulé ou échoué',
      ));
    }
  }

  /// Handle check-in QR code scan
  Future<void> _onCheckInQRScanned(
    CheckInQRScanned event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const CheckInVerifying());

    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const AttendanceError('Utilisateur non authentifié'));
      return;
    }

    final userId = authState.user.id;

    // CRITICAL: pinCode sent to backend (using '0000' as placeholder for device-unlocked check-in)
    final result = await _checkInUseCase(
      userId: userId,
      qrCode: event.qrCode,
      pinCode: '0000', // Placeholder when device unlock is used
      checkInTime: DateTime.now(),
      location: null, // Optional: could be obtained from GPS if needed
    );

    result.fold(
      (failure) => emit(AttendanceError(_mapFailureToMessage(failure))),
      (attendance) => emit(CheckInSuccess(attendance)),
    );
  }

  /// Handle check-out device unlock request
  Future<void> _onCheckOutUnlockRequested(
    CheckOutUnlockRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const CheckOutUnlockInProgress());

    final canCheck = await _deviceUnlockService.canCheckDeviceUnlock();
    if (!canCheck) {
      emit(const CheckOutUnlockFailure(
        'Le déverrouillage de l\'appareil n\'est pas disponible sur cet appareil',
      ));
      return;
    }

    // CRITICAL: biometricOnly: false accepts ALL methods
    final isAuthenticated = await _deviceUnlockService.authenticate(
      localizedReason: 'Déverrouillez votre appareil pour pointer',
    );

    if (isAuthenticated) {
      emit(const CheckOutUnlockSuccess());
    } else {
      emit(const CheckOutUnlockFailure(
        'Déverrouillage annulé ou échoué',
      ));
    }
  }

  /// Handle check-out QR code scan
  Future<void> _onCheckOutQRScanned(
    CheckOutQRScanned event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const CheckOutVerifying());

    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const AttendanceError('Utilisateur non authentifié'));
      return;
    }

    final userId = authState.user.id;

    // CRITICAL: pinCode sent to backend (using '0000' as placeholder for device-unlocked check-out)
    final result = await _checkOutUseCase(
      userId: userId,
      qrCode: event.qrCode,
      pinCode: '0000', // Placeholder when device unlock is used
      checkOutTime: DateTime.now(),
      location: null, // Optional: could be obtained from GPS if needed
    );

    result.fold(
      (failure) => emit(AttendanceError(_mapFailureToMessage(failure))),
      (attendance) => emit(CheckOutSuccess(attendance)),
    );
  }

  /// Handle attendance reset
  Future<void> _onAttendanceReset(
    AttendanceReset event,
    Emitter<AttendanceState> emit,
  ) async {
    // Get current state
    if (state is AttendanceLoaded) {
      // Stay in loaded state
      emit(state);
    } else {
      emit(const AttendanceInitial());
    }
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
