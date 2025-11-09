/// Base Exception Class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server Exception - Erreur c\u00f4t\u00e9 serveur (4xx, 5xx)
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Network Exception - Pas de connexion internet
class NetworkException extends AppException {
  NetworkException({
    String message = 'Pas de connexion internet',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Unauthorized Exception - Token invalide ou expir\u00e9 (401)
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Session expir\u00e9e. Veuillez vous reconnecter.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Forbidden Exception - Acc\u00e8s interdit (403)
class ForbiddenException extends AppException {
  ForbiddenException({
    String message = 'Acc\u00e8s refus\u00e9.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Not Found Exception - Ressource non trouv\u00e9e (404)
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'Ressource non trouv\u00e9e.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Validation Exception - Erreur de validation des donn\u00e9es
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    String message = 'Donn\u00e9es invalides.',
    super.code,
    super.details,
    this.fieldErrors,
  }) : super(message: message);

  @override
  String toString() => 'ValidationException: $message${fieldErrors != null ? ' - $fieldErrors' : ''}';
}

/// Device Unlock Exception - \u00c9chec du d\u00e9verrouillage du t\u00e9l\u00e9phone natif
class DeviceUnlockException extends AppException {
  final String reason;

  DeviceUnlockException({
    required this.reason,
    String message = '\u00c9chec du d\u00e9verrouillage de l\'appareil.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'DeviceUnlockException: $message - Reason: $reason';
}

/// QR Code Exception - Erreur lors du scan QR
class QRCodeException extends AppException {
  QRCodeException({
    String message = 'Erreur lors du scan du QR code.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'QRCodeException: $message';
}

/// Permission Exception - Permission refus\u00e9e par l'utilisateur
class PermissionException extends AppException {
  final String permission;

  PermissionException({
    required this.permission,
    String message = 'Permission refus\u00e9e.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'PermissionException: $message - Permission: $permission';
}

/// Storage Exception - Erreur lors de la lecture/\u00e9criture du stockage s\u00e9curis\u00e9
class StorageException extends AppException {
  StorageException({
    String message = 'Erreur de stockage.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'StorageException: $message';
}

/// Cache Exception - Erreur lors de la lecture du cache
class CacheException extends AppException {
  CacheException({
    String message = 'Erreur de cache.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'CacheException: $message';
}

/// Timeout Exception - Requ\u00eate trop longue
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'La requ\u00eate a expir\u00e9. Veuillez r\u00e9essayer.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Account Locked Exception - Compte bloqu\u00e9 temporairement
class AccountLockedException extends AppException {
  final DateTime? lockedUntil;

  AccountLockedException({
    this.lockedUntil,
    String message = 'Compte temporairement bloqu\u00e9.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'AccountLockedException: $message${lockedUntil != null ? ' jusqu\'\u00e0 $lockedUntil' : ''}';
}

/// Invalid PIN Exception - Code PIN incorrect
class InvalidPinException extends AppException {
  final int? attemptsRemaining;

  InvalidPinException({
    this.attemptsRemaining,
    String message = 'Code PIN incorrect.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'InvalidPinException: $message${attemptsRemaining != null ? ' ($attemptsRemaining tentatives restantes)' : ''}';
}
