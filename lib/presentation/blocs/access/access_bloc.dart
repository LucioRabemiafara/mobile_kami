import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/device_unlock_service.dart';
import '../../../domain/usecases/access/verify_access_usecase.dart';
import '../../../domain/usecases/access/verify_pin_usecase.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'access_event.dart';
import 'access_state.dart';

/// Access BLoC
///
/// Manages zone access control workflow
/// Handles device unlock, QR scanning, and PIN verification
class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final VerifyAccessUseCase _verifyAccessUseCase;
  final VerifyPinUseCase _verifyPinUseCase;
  final DeviceUnlockService _deviceUnlockService;
  final AuthBloc _authBloc;

  AccessBloc({
    required VerifyAccessUseCase verifyAccessUseCase,
    required VerifyPinUseCase verifyPinUseCase,
    required DeviceUnlockService deviceUnlockService,
    required AuthBloc authBloc,
  })  : _verifyAccessUseCase = verifyAccessUseCase,
        _verifyPinUseCase = verifyPinUseCase,
        _deviceUnlockService = deviceUnlockService,
        _authBloc = authBloc,
        super(const AccessInitial()) {
    // Register event handlers
    on<DeviceUnlockRequested>(_onDeviceUnlockRequested);
    on<QRCodeScanned>(_onQRCodeScanned);
    on<PINSubmitted>(_onPINSubmitted);
    on<AccessReset>(_onAccessReset);
  }

  /// Handle Device Unlock Requested Event
  ///
  /// Attempts to unlock device using native authentication
  /// (fingerprint, face, pattern, PIN, password)
  Future<void> _onDeviceUnlockRequested(
    DeviceUnlockRequested event,
    Emitter<AccessState> emit,
  ) async {
    emit(const DeviceUnlockInProgress());

    try {
      // Check if device supports unlock
      final isDeviceSupported = await _deviceUnlockService.isDeviceSupported();

      if (!isDeviceSupported) {
        emit(const DeviceUnlockFailed(
          'Votre appareil ne supporte pas le déverrouillage sécurisé.\n\n'
          'Veuillez configurer une méthode de déverrouillage dans les paramètres de votre appareil (empreinte, face, schéma, PIN ou mot de passe).',
        ));
        return;
      }

      // Check if device unlock is available
      final canCheck = await _deviceUnlockService.canCheckDeviceUnlock();

      if (!canCheck) {
        emit(const DeviceUnlockFailed(
          'Aucune méthode de déverrouillage configurée.\n\n'
          'Veuillez configurer au moins une méthode de déverrouillage dans les paramètres de votre appareil :\n'
          '• Empreinte digitale\n'
          '• Reconnaissance faciale\n'
          '• Schéma\n'
          '• Code PIN\n'
          '• Mot de passe',
        ));
        return;
      }

      // Get available methods for debugging
      final availableMethods = await _deviceUnlockService.getAvailableMethodsAsStrings();
      print('📱 Méthodes de déverrouillage disponibles: $availableMethods');

      // Attempt device authentication
      // biometricOnly: false means accept ALL unlock methods
      // (fingerprint, face, pattern, PIN, password)
      final isAuthenticated = await _deviceUnlockService.authenticate(
        localizedReason: 'Déverrouillez votre appareil pour scanner le QR code',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (isAuthenticated) {
        print('✅ Déverrouillage réussi');
        emit(const DeviceUnlockSuccess());
      } else {
        print('❌ Déverrouillage échoué ou annulé');
        emit(const DeviceUnlockFailed(
          'Déverrouillage annulé.\n\n'
          'Veuillez réessayer et compléter le déverrouillage de votre appareil.',
        ));
      }
    } catch (e) {
      print('🔴 Erreur de déverrouillage: $e');

      String errorMessage = 'Erreur lors du déverrouillage.\n\n';

      // Analyse de l'erreur pour donner un message plus précis
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('no hardware') || errorString.contains('not available')) {
        errorMessage += 'Votre appareil ne dispose pas de capteur biométrique.\n'
                       'Assurez-vous d\'avoir configuré un code PIN, schéma ou mot de passe.';
      } else if (errorString.contains('not enrolled') || errorString.contains('no fingerprints')) {
        errorMessage += 'Aucune méthode de déverrouillage enregistrée.\n'
                       'Configurez une méthode dans les paramètres de votre appareil.';
      } else if (errorString.contains('lockout')) {
        errorMessage += 'Trop de tentatives échouées.\n'
                       'Veuillez réessayer dans quelques instants.';
      } else if (errorString.contains('permission')) {
        errorMessage += 'Permission refusée.\n'
                       'L\'application n\'a pas accès au déverrouillage de l\'appareil.';
      } else {
        errorMessage += 'Détails: ${e.toString()}';
      }

      emit(DeviceUnlockFailed(errorMessage));
    }
  }

  /// Handle QR Code Scanned Event
  ///
  /// Verifies zone access after QR code is scanned
  /// Note: Native device unlock must be completed BEFORE this is called
  Future<void> _onQRCodeScanned(
    QRCodeScanned event,
    Emitter<AccessState> emit,
  ) async {
    print('📱 AccessBloc: QRCodeScanned event received');
    print('📱 QR Code: ${event.qrCode}');

    emit(const AccessVerifying());
    print('📱 State: AccessVerifying emitted');

    // Get current user from AuthBloc
    final authState = _authBloc.state;
    print('📱 AuthState: $authState');

    if (authState is! AuthAuthenticated) {
      print('❌ User not authenticated');
      emit(const AccessError('Utilisateur non authentifié'));
      return;
    }

    final userId = authState.user.id;
    print('📱 User ID: $userId');

    // Call verify access use case with optional device info
    print('📱 Calling verifyAccessUseCase...');
    final result = await _verifyAccessUseCase(
      userId: userId,
      qrCode: event.qrCode,
      deviceInfo: 'Mobile App', // Optional: can be more detailed
      ipAddress: null, // Optional: can be obtained if needed
    );

    print('📱 API Result received');

    result.fold(
      (failure) {
        // Handle specific failures
        print('❌ API Failure: $failure');
        final errorMessage = _mapFailureToMessage(failure);
        print('❌ Error message: $errorMessage');
        emit(AccessError(errorMessage));
      },
      (response) {
        // Handle response based on status
        print('✅ API Success: ${response.toString()}');
        final zoneName = response.zoneName ?? 'Zone inconnue';
        print('📱 Zone: $zoneName, Status: ${response.status}');

        if (response.status == 'GRANTED') {
          print('✅ Access GRANTED');
          // Access granted for LOW/MEDIUM security zones
          emit(AccessGranted(zoneName));
        } else if (response.status == 'PENDING_PIN') {
          // High security zone requires PIN
          // eventId is now returned instead of tempToken
          final eventId = response.eventId ?? 0;
          if (eventId == 0) {
            emit(const AccessError('Identifiant d\'événement manquant'));
            return;
          }
          emit(AccessPendingPIN(
            zoneName: zoneName,
            eventId: eventId,
          ));
        } else if (response.status == 'DENIED') {
          // Access denied
          emit(AccessDenied(
            zoneName: zoneName,
            reason: response.reason ?? 'Accès non autorisé',
          ));
        } else {
          emit(const AccessError('Réponse inattendue du serveur'));
        }
      },
    );
  }

  /// Handle PIN Submitted Event
  ///
  /// Verifies PIN code for high-security zones
  /// 3 attempts max, then account locked for 30 minutes
  Future<void> _onPINSubmitted(
    PINSubmitted event,
    Emitter<AccessState> emit,
  ) async {
    emit(const PINVerifying());

    // Get current user from AuthBloc
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const AccessError('Utilisateur non authentifié'));
      return;
    }

    final userId = authState.user.id;

    final result = await _verifyPinUseCase(
      userId: userId,
      pinCode: event.pinCode,
      eventId: event.eventId,
    );

    result.fold(
      (failure) {
        // Handle specific PIN failures
        if (failure is InvalidPinFailure) {
          final attemptsRemaining = failure.attemptsRemaining ?? 0;
          if (attemptsRemaining > 0) {
            emit(PINIncorrect(attemptsRemaining));
          } else {
            // No attempts remaining, should be locked
            emit(const AccessError('Code PIN incorrect'));
          }
        } else if (failure is AccountLockedFailure) {
          final lockedUntil = failure.lockedUntil;
          if (lockedUntil != null) {
            emit(AccountLocked(lockedUntil));
          } else {
            emit(const AccessError('Compte bloqué. Contactez l\'administrateur.'));
          }
        } else {
          final errorMessage = _mapFailureToMessage(failure);
          emit(AccessError(errorMessage));
        }
      },
      (response) {
        // PIN verified successfully
        if (response.status == 'GRANTED') {
          final zoneName = response.zoneName ?? 'Zone inconnue';
          emit(AccessGranted(zoneName));
        } else {
          emit(const AccessError('Accès refusé malgré le PIN correct'));
        }
      },
    );
  }

  /// Handle Access Reset Event
  ///
  /// Resets access flow to initial state
  Future<void> _onAccessReset(
    AccessReset event,
    Emitter<AccessState> emit,
  ) async {
    emit(const AccessInitial());
  }

  /// Map Failure to User-Friendly Message
  ///
  /// Converts technical failures to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is QRCodeFailure) {
      return failure.message ?? 'QR code invalide ou expiré';
    } else if (failure is UnauthorizedFailure) {
      return 'Session expirée. Reconnectez-vous.';
    } else if (failure is ForbiddenFailure) {
      return 'Accès interdit';
    } else if (failure is AccountLockedFailure) {
      final lockedUntil = failure.lockedUntil;
      if (lockedUntil != null) {
        final now = DateTime.now();
        if (lockedUntil.isAfter(now)) {
          final duration = lockedUntil.difference(now);
          final minutes = duration.inMinutes;
          return 'Compte bloqué pendant $minutes minute${minutes > 1 ? 's' : ''}';
        }
      }
      return 'Compte bloqué temporairement';
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
