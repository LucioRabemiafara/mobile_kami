import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../errors/exceptions.dart';
import '../services/storage_service.dart';
import 'api_endpoints.dart';

/// Auth Interceptor for automatic JWT token management
///
/// ⭐ CRITICAL: Handles automatic token refresh on 401 errors
///
/// Features:
/// 1. Automatically adds Bearer token to all requests
/// 2. Intercepts 401 errors and refreshes token
/// 3. Retries original request with new token
/// 4. Prevents infinite loops by using separate Dio for refresh
@injectable
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio;

  // Separate Dio instance for refresh requests (to avoid infinite loops)
  late final Dio _refreshDio;

  // Lock to prevent multiple simultaneous refresh requests
  bool _isRefreshing = false;

  AuthInterceptor(this._storageService, this._dio) {
    // Create separate Dio for refresh requests WITHOUT interceptors
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for login and refresh endpoints
    if (_shouldSkipToken(options.path)) {
      return handler.next(options);
    }

    try {
      // Get access token from storage
      final accessToken = await _storageService.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        // Add Bearer token to headers
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StorageException(
            message: 'Failed to get access token',
            details: e,
          ),
        ),
      );
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Skip refresh for login and refresh endpoints
      if (_shouldSkipRefresh(err.requestOptions.path)) {
        return handler.reject(err);
      }

      // Prevent multiple simultaneous refresh requests
      if (_isRefreshing) {
        // Wait for the current refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
        // Retry original request
        return _retryRequest(err.requestOptions, handler);
      }

      // Try to refresh token
      _isRefreshing = true;
      try {
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          // Save new token
          await _storageService.saveAccessToken(newAccessToken);

          // Retry original request with new token
          _isRefreshing = false;
          return _retryRequest(err.requestOptions, handler);
        } else {
          // Refresh failed, logout user
          _isRefreshing = false;
          await _handleRefreshFailure();
          return handler.reject(err);
        }
      } catch (e) {
        // Refresh failed, logout user
        _isRefreshing = false;
        await _handleRefreshFailure();
        return handler.reject(err);
      }
    }

    // For other errors, pass through
    handler.next(err);
  }

  /// Check if token should be skipped for this endpoint
  bool _shouldSkipToken(String path) {
    return path.contains(ApiEndpoints.login) ||
           path.contains(ApiEndpoints.refresh);
  }

  /// Check if refresh should be skipped for this endpoint
  bool _shouldSkipRefresh(String path) {
    return path.contains(ApiEndpoints.login) ||
           path.contains(ApiEndpoints.refresh);
  }

  /// Refresh access token using refresh token
  ///
  /// ⭐ CRITICAL: Uses separate Dio instance to avoid infinite loops
  Future<String?> _refreshToken() async {
    try {
      // Get refresh token from storage
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw UnauthorizedException(
          message: 'No refresh token available',
        );
      }

      // Call refresh endpoint using separate Dio (no interceptors)
      final response = await _refreshDio.post(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        return newAccessToken;
      }

      return null;
    } catch (e) {
      // Refresh failed
      return null;
    }
  }

  /// Retry original request with new token
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Get new access token
      final accessToken = await _storageService.getAccessToken();

      if (accessToken != null) {
        // Update request headers with new token
        requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Retry request
      final response = await _dio.fetch(requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }

  /// Handle refresh failure (logout user)
  Future<void> _handleRefreshFailure() async {
    try {
      // Clear all stored data
      await _storageService.clear();
    } catch (e) {
      // Ignore error during cleanup
    }
  }
}

/// Logging Interceptor for debugging
@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📤 Headers: ${options.headers}');
    if (options.data != null) {
      print('📤 Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📥 Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ Message: ${err.message}');
    if (err.response?.data != null) {
      print('❌ Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

/// Timeout Interceptor to convert timeout errors
@injectable
class TimeoutInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: TimeoutException(
            message: 'La requête a expiré. Vérifiez votre connexion.',
          ),
        ),
      );
    } else {
      handler.next(err);
    }
  }
}

/// Network Error Interceptor to convert connection errors
@injectable
class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: NetworkException(
            message: 'Pas de connexion internet. Vérifiez votre connexion.',
          ),
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
