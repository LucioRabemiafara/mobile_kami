import 'package:equatable/equatable.dart';

/// Base Failure Class
/// Utilise Equatable pour comparer les failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server Failure - Erreur c\u00f4t\u00e9 serveur (4xx, 5xx)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, details, statusCode];

  @override
  String toString() => 'ServerFailure: $message (Status: $statusCode)';
}

/// Network Failure - Pas de connexion internet
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Pas de connexion internet. V\u00e9rifiez votre connexion.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Unauthorized Failure - Token invalide ou expir\u00e9 (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Session expir\u00e9e. Veuillez vous reconnecter.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'UnauthorizedFailure: $message';
}

/// Forbidden Failure - Acc\u00e8s interdit (403)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    String message = 'Acc\u00e8s refus\u00e9. Vous n\'avez pas les permissions n\u00e9cessaires.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'ForbiddenFailure: $message';
}

/// Not Found Failure - Ressource non trouv\u00e9e (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Ressource non trouv\u00e9e.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'NotFoundFailure: $message';
}

/// Validation Failure - Erreur de validation des donn\u00e9es
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    String message = 'Donn\u00e9es invalides. V\u00e9rifiez les champs.',
    super.code,
    super.details,
    this.fieldErrors,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, details, fieldErrors];

  @override
  String toString() => 'ValidationFailure: $message${fieldErrors != null ? ' - $fieldErrors' : ''}';
}

/// Device Unlock Failure - \u00c9chec du d\u00e9verrouillage du t\u00e9l\u00e9phone natif
class DeviceUnlockFailure extends Failure {
  final String reason;

  const DeviceUnlockFailure({
    required this.reason,
    String message = '\u00c9chec du d\u00e9verrouillage de l\'appareil. Veuillez r\u00e9essayer.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, details, reason];

  @override
  String toString() => 'DeviceUnlockFailure: $message - Reason: $reason';
}

/// QR Code Failure - Erreur lors du scan QR
class QRCodeFailure extends Failure {
  const QRCodeFailure({
    String message = 'Erreur lors du scan du QR code. Veuillez r\u00e9essayer.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'QRCodeFailure: $message';
}

/// Permission Failure - Permission refus\u00e9e par l'utilisateur
class PermissionFailure extends Failure {
  final String permission;

  const PermissionFailure({
    required this.permission,
    String message = 'Permission refus\u00e9e. Veuillez autoriser l\'acc\u00e8s dans les param\u00e8tres.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, details, permission];

  @override
  String toString() => 'PermissionFailure: $message - Permission: $permission';
}

/// Storage Failure - Erreur lors de la lecture/\u00e9criture du stockage s\u00e9curis\u00e9
class StorageFailure extends Failure {
  const StorageFailure({
    String message = 'Erreur de stockage. Veuillez r\u00e9essayer.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'StorageFailure: $message';
}

/// Cache Failure - Erreur lors de la lecture du cache
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erreur de cache.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// Timeout Failure - Requ\u00eate trop longue
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'La requ\u00eate a expir\u00e9. V\u00e9rifiez votre connexion et r\u00e9essayez.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'TimeoutFailure: $message';
}

/// Account Locked Failure - Compte bloqu\u00e9 temporairement
class AccountLockedFailure extends Failure {
  final DateTime? lockedUntil;

  const AccountLockedFailure({
    this.lockedUntil,
    String message = 'Compte temporairement bloqu\u00e9 apr\u00e8s plusieurs tentatives \u00e9chou\u00e9es.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, details, lockedUntil];

  @override
  String toString() => 'AccountLockedFailure: $message${lockedUntil != null ? ' jusqu\'\u00e0 $lockedUntil' : ''}';
}

/// Invalid PIN Failure - Code PIN incorrect
class InvalidPinFailure extends Failure {
  final int? attemptsRemaining;

  const InvalidPinFailure({
    this.attemptsRemaining,
    String message = 'Code PIN incorrect.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, details, attemptsRemaining];

  @override
  String toString() => 'InvalidPinFailure: $message${attemptsRemaining != null ? ' ($attemptsRemaining tentatives restantes)' : ''}';
}

/// Generic Failure - Erreur g\u00e9n\u00e9rique
class GenericFailure extends Failure {
  const GenericFailure({
    String message = 'Une erreur inattendue est survenue. Veuillez r\u00e9essayer.',
    super.code,
    super.details,
  }) : super(message: message);

  @override
  String toString() => 'GenericFailure: $message';
}
