import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';

/// API Error Handler
///
/// Centralized error handling for all API calls
class ApiErrorHandler {
  /// Handle DioException and convert to appropriate Exception
  static Exception handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'La requête a expiré. Vérifiez votre connexion.',
          details: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Pas de connexion internet. Vérifiez votre connexion.',
          details: error,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return ServerException(
          message: 'Requête annulée',
          details: error,
        );

      default:
        return ServerException(
          message: 'Une erreur est survenue',
          details: error,
        );
    }
  }

  /// Handle HTTP response errors (4xx, 5xx)
  static Exception _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract error message from response if available
    String message = 'Une erreur est survenue';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
                data['error'] as String? ??
                message;
    }

    switch (statusCode) {
      case 400:
        // Bad Request - Validation error
        return ValidationException(
          message: message,
          details: error,
          fieldErrors: _extractFieldErrors(data),
        );

      case 401:
        // Unauthorized - Invalid or expired token
        return UnauthorizedException(
          message: message.isNotEmpty ? message : 'Session expirée. Veuillez vous reconnecter.',
          details: error,
        );

      case 403:
        // Forbidden - Insufficient permissions
        return ForbiddenException(
          message: message.isNotEmpty ? message : 'Accès refusé.',
          details: error,
        );

      case 404:
        // Not Found
        return NotFoundException(
          message: message.isNotEmpty ? message : 'Ressource non trouvée.',
          details: error,
        );

      case 409:
        // Conflict - Account locked or similar
        return _handleConflictError(data, error);

      case 500:
      case 502:
      case 503:
      case 504:
        // Server errors
        return ServerException(
          message: 'Erreur serveur. Veuillez réessayer plus tard.',
          statusCode: statusCode,
          details: error,
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          details: error,
        );
    }
  }

  /// Extract field errors from validation error response
  static Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) => MapEntry(key, value.toString()));
      }
    }
    return null;
  }

  /// Handle 409 Conflict errors (account locked, etc.)
  static Exception _handleConflictError(dynamic data, DioException error) {
    if (data is Map<String, dynamic>) {
      // Check for account locked
      if (data.containsKey('accountLockedUntil')) {
        final lockedUntilStr = data['accountLockedUntil'] as String?;
        DateTime? lockedUntil;
        if (lockedUntilStr != null) {
          lockedUntil = DateTime.tryParse(lockedUntilStr);
        }

        return AccountLockedException(
          message: data['message'] as String? ?? 'Compte temporairement bloqué.',
          lockedUntil: lockedUntil,
          details: error,
        );
      }
    }

    return ServerException(
      message: 'Conflit. Veuillez réessayer.',
      statusCode: 409,
      details: error,
    );
  }
}
