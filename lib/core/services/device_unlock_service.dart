import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import '../errors/exceptions.dart';

/// Service for device unlock verification using native phone security
///
/// ⭐ CRITICAL: This service verifies the NATIVE phone unlock, NOT app-specific biometrics
///
/// Supported unlock methods:
/// - Android: Fingerprint, Face Unlock, Pattern, PIN, Password
/// - iOS: Touch ID, Face ID, Phone Passcode
///
/// This uses the SAME security method the user uses to unlock their phone screen.
/// The app simply verifies that the phone has been unlocked with native security.
@lazySingleton
class DeviceUnlockService {
  final LocalAuthentication _localAuth;

  DeviceUnlockService() : _localAuth = LocalAuthentication();

  /// Check if device can check for device unlock
  ///
  /// Returns true if the device supports at least one unlock method
  Future<bool> canCheckDeviceUnlock() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (e) {
      throw DeviceUnlockException(
        reason: 'Failed to check device unlock capability',
        message: 'Impossible de vérifier les capacités de déverrouillage de l\'appareil',
        details: e,
      );
    }
  }

  /// Get available unlock methods on the device
  ///
  /// Returns list of BiometricType (fingerprint, face, iris, etc.)
  /// Note: This may not include non-biometric methods like PIN/Pattern/Password
  Future<List<BiometricType>> getAvailableMethods() async {
    try {
      final canCheck = await canCheckDeviceUnlock();
      if (!canCheck) {
        return [];
      }

      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      throw DeviceUnlockException(
        reason: 'Failed to get available unlock methods',
        message: 'Impossible de récupérer les méthodes de déverrouillage disponibles',
        details: e,
      );
    }
  }

  /// Authenticate using native device unlock
  ///
  /// ⭐ CRITICAL: Uses biometricOnly: FALSE to accept ALL unlock methods:
  /// - Biometric: Fingerprint, Face ID, Touch ID
  /// - Non-biometric: Pattern, PIN, Password
  ///
  /// This is the SAME unlock method the user uses to unlock their phone screen.
  ///
  /// Parameters:
  /// - [localizedReason]: Message shown to the user during authentication
  /// - [useErrorDialogs]: Show system error dialogs (default: false)
  /// - [stickyAuth]: Keep auth dialog visible if app goes to background (default: true)
  ///
  /// Returns:
  /// - true: Device was successfully unlocked
  /// - false: User cancelled or authentication failed
  ///
  /// Throws:
  /// - DeviceUnlockException: If an error occurs during authentication
  Future<bool> authenticate({
    String localizedReason = 'Déverrouillez votre téléphone pour continuer',
    bool useErrorDialogs = false,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if device supports unlock
      final canCheck = await canCheckDeviceUnlock();
      if (!canCheck) {
        throw DeviceUnlockException(
          reason: 'Device does not support device unlock',
          message: 'Votre appareil ne supporte pas le déverrouillage sécurisé',
        );
      }

      print('🔓 Starting device authentication...');
      print('📱 Localized reason: $localizedReason');

      // ⭐ CRITICAL: biometricOnly = FALSE
      // This allows ALL unlock methods (not just biometrics):
      // - Fingerprint
      // - Face recognition
      // - Pattern
      // - PIN
      // - Password
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: false, // ⭐ ACCEPT ALL UNLOCK METHODS
          stickyAuth: stickyAuth, // Keep auth dialog visible if app goes to background
          useErrorDialogs: useErrorDialogs, // Use the parameter value
        ),
      );

      print('✅ Authentication result: $authenticated');
      return authenticated;
    } on DeviceUnlockException {
      // Re-throw our custom exception
      print('🔴 DeviceUnlockException caught and re-thrown');
      rethrow;
    } catch (e) {
      print('🔴 Authentication exception caught: $e');
      print('🔴 Exception type: ${e.runtimeType}');

      // Check for FragmentActivity error (Android configuration issue)
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('no_fragment_activity') ||
          errorString.contains('fragmentactivity')) {
        print('⚠️ FragmentActivity error - MainActivity needs to extend FlutterFragmentActivity');
        // Return false instead of throwing - allows app to continue
        return false;
      }

      // Check if it's a cancellation (user pressed back/cancel)
      if (errorString.contains('cancel') ||
          errorString.contains('user') ||
          errorString.contains('lockauthfailed') ||
          errorString.contains('authenticationfailed')) {
        // User cancelled - return false instead of throwing
        print('ℹ️ User cancelled authentication');
        return false;
      }

      // Wrap other exceptions in DeviceUnlockException
      throw DeviceUnlockException(
        reason: 'Authentication failed: ${e.toString()}',
        message: 'Échec du déverrouillage de l\'appareil. Veuillez réessayer.',
        details: e,
      );
    }
  }

  /// Stop authentication (cancel ongoing authentication)
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      throw DeviceUnlockException(
        reason: 'Failed to stop authentication',
        message: 'Impossible d\'arrêter l\'authentification',
        details: e,
      );
    }
  }

  /// Get available biometric types as readable strings
  Future<List<String>> getAvailableMethodsAsStrings() async {
    try {
      final methods = await getAvailableMethods();
      return methods.map((type) => _biometricTypeToString(type)).toList();
    } catch (e) {
      throw DeviceUnlockException(
        reason: 'Failed to get available methods as strings',
        message: 'Impossible de récupérer les méthodes disponibles',
        details: e,
      );
    }
  }

  /// Convert BiometricType to readable string
  String _biometricTypeToString(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Reconnaissance faciale';
      case BiometricType.fingerprint:
        return 'Empreinte digitale';
      case BiometricType.iris:
        return 'Reconnaissance de l\'iris';
      case BiometricType.strong:
        return 'Authentification forte';
      case BiometricType.weak:
        return 'Authentification faible';
      default:
        return 'Méthode inconnue';
    }
  }

  /// Check if device has enrolled biometrics
  ///
  /// Note: This only checks for biometrics, not other unlock methods like PIN/Pattern
  Future<bool> hasEnrolledBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is supported (can use any form of authentication)
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
}
