import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Core
import 'core/api/api_endpoints.dart';
import 'core/api/dio_client.dart';
import 'core/api/api_interceptors.dart';
import 'core/services/storage_service.dart';
import 'core/services/device_unlock_service.dart';
import 'core/services/notification_service.dart';

// Data Sources (APIs)
import 'data/data_sources/remote/auth_api.dart';
import 'data/data_sources/remote/access_api.dart';
import 'data/data_sources/remote/attendance_api.dart';
import 'data/data_sources/remote/user_api.dart';
import 'data/data_sources/remote/access_request_api.dart';
import 'data/data_sources/remote/dashboard_api.dart';
import 'data/data_sources/remote/zone_api.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/access_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/access_request_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/zone_repository.dart';

// UseCases - Auth
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/get_cached_user_usecase.dart';
import 'domain/usecases/auth/is_authenticated_usecase.dart';

// UseCases - Access
import 'domain/usecases/access/verify_access_usecase.dart';
import 'domain/usecases/access/verify_pin_usecase.dart';
import 'domain/usecases/access/get_access_history_usecase.dart';

// UseCases - Attendance
import 'domain/usecases/attendance/check_in_usecase.dart';
import 'domain/usecases/attendance/check_out_usecase.dart';
import 'domain/usecases/attendance/get_today_attendance_usecase.dart';
import 'domain/usecases/attendance/get_attendance_history_usecase.dart';

// UseCases - User
import 'domain/usecases/user/get_user_usecase.dart';
import 'domain/usecases/user/get_access_zones_usecase.dart';

// UseCases - Access Request
import 'domain/usecases/access_request/get_my_requests_usecase.dart';
import 'domain/usecases/access_request/create_request_usecase.dart';

// UseCases - Dashboard
import 'domain/usecases/dashboard/get_kpis_usecase.dart';

// UseCases - Zone
import 'domain/usecases/zone/get_all_zones_usecase.dart';

// BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/access/access_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/blocs/attendance/attendance_bloc.dart';
import 'presentation/blocs/access_request/access_request_bloc.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
///
/// Call this in main() before runApp()
Future<void> configureDependencies() async {
  // ========== EXTERNAL DEPENDENCIES ==========

  // FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );

  // Dio instance for regular API calls (with interceptors)
  getIt.registerLazySingleton<Dio>(
    () {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      dio.interceptors.add(
        AuthInterceptor(
          getIt<StorageService>(),
          dio,
        ),
      );

      // Add logger in debug mode
      if (kDebugMode) {
        dio.interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );
      }

      return dio;
    },
    instanceName: 'mainDio',
  );

  // Separate Dio instance for token refresh (NO interceptors to avoid loops)
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
    instanceName: 'refreshDio',
  );

  // ========== CORE SERVICES ==========

  getIt.registerLazySingleton<StorageService>(
    () => StorageService(),
  );

  getIt.registerLazySingleton<DeviceUnlockService>(
    () => DeviceUnlockService(),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<Dio>(instanceName: 'mainDio')),
  );

  // ========== DATA SOURCES (APIs) ==========

  getIt.registerLazySingleton<AuthApi>(
    () => AuthApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AccessApi>(
    () => AccessApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AttendanceApi>(
    () => AttendanceApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<UserApi>(
    () => UserApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AccessRequestApi>(
    () => AccessRequestApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<DashboardApi>(
    () => DashboardApiImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<ZoneApi>(
    () => ZoneApiImpl(getIt<DioClient>()),
  );

  // ========== REPOSITORIES ==========

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthApi>(),
      getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<AccessRepository>(
    () => AccessRepositoryImpl(getIt<AccessApi>()),
  );

  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(getIt<AttendanceApi>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserApi>()),
  );

  getIt.registerLazySingleton<AccessRequestRepository>(
    () => AccessRequestRepositoryImpl(getIt<AccessRequestApi>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardApi>()),
  );

  getIt.registerLazySingleton<ZoneRepository>(
    () => ZoneRepositoryImpl(getIt<ZoneApi>()),
  );

  // ========== USE CASES ==========

  // Auth UseCases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCachedUserUseCase>(
    () => GetCachedUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<IsAuthenticatedUseCase>(
    () => IsAuthenticatedUseCase(getIt<AuthRepository>()),
  );

  // Access UseCases
  getIt.registerLazySingleton<VerifyAccessUseCase>(
    () => VerifyAccessUseCase(getIt<AccessRepository>()),
  );

  getIt.registerLazySingleton<VerifyPinUseCase>(
    () => VerifyPinUseCase(getIt<AccessRepository>()),
  );

  getIt.registerLazySingleton<GetAccessHistoryUseCase>(
    () => GetAccessHistoryUseCase(getIt<AccessRepository>()),
  );

  // Attendance UseCases
  getIt.registerLazySingleton<CheckInUseCase>(
    () => CheckInUseCase(getIt<AttendanceRepository>()),
  );

  getIt.registerLazySingleton<CheckOutUseCase>(
    () => CheckOutUseCase(getIt<AttendanceRepository>()),
  );

  getIt.registerLazySingleton<GetTodayAttendanceUseCase>(
    () => GetTodayAttendanceUseCase(getIt<AttendanceRepository>()),
  );

  getIt.registerLazySingleton<GetAttendanceHistoryUseCase>(
    () => GetAttendanceHistoryUseCase(getIt<AttendanceRepository>()),
  );

  // User UseCases
  getIt.registerLazySingleton<GetUserUseCase>(
    () => GetUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<GetAccessZonesUseCase>(
    () => GetAccessZonesUseCase(getIt<UserRepository>()),
  );

  // Access Request UseCases
  getIt.registerLazySingleton<GetMyRequestsUseCase>(
    () => GetMyRequestsUseCase(getIt<AccessRequestRepository>()),
  );

  getIt.registerLazySingleton<CreateRequestUseCase>(
    () => CreateRequestUseCase(getIt<AccessRequestRepository>()),
  );

  // Dashboard UseCases
  getIt.registerLazySingleton<GetKpisUseCase>(
    () => GetKpisUseCase(getIt<DashboardRepository>()),
  );

  // Zone UseCases
  getIt.registerLazySingleton<GetAllZonesUseCase>(
    () => GetAllZonesUseCase(getIt<ZoneRepository>()),
  );

  // ========== BLoCs ==========

  // BLoCs are registered with registerFactory (new instance each time)
  // This ensures each screen gets its own BLoC instance

  // AuthBloc
  // AuthBloc MUST be a singleton to maintain authentication state across the app
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCachedUserUseCase: getIt<GetCachedUserUseCase>(),
      isAuthenticatedUseCase: getIt<IsAuthenticatedUseCase>(),
    ),
  );

  // AccessBloc
  getIt.registerFactory<AccessBloc>(
    () => AccessBloc(
      verifyAccessUseCase: getIt<VerifyAccessUseCase>(),
      verifyPinUseCase: getIt<VerifyPinUseCase>(),
      getAccessHistoryUseCase: getIt<GetAccessHistoryUseCase>(),
      deviceUnlockService: getIt<DeviceUnlockService>(),
      authBloc: getIt<AuthBloc>(),
    ),
  );

  // DashboardBloc
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getKpisUseCase: getIt<GetKpisUseCase>(),
    ),
  );

  // AttendanceBloc
  getIt.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      getTodayAttendanceUseCase: getIt<GetTodayAttendanceUseCase>(),
      checkInUseCase: getIt<CheckInUseCase>(),
      checkOutUseCase: getIt<CheckOutUseCase>(),
      deviceUnlockService: getIt<DeviceUnlockService>(),
      authBloc: getIt<AuthBloc>(),
    ),
  );

  // AccessRequestBloc
  getIt.registerFactory<AccessRequestBloc>(
    () => AccessRequestBloc(
      getMyRequestsUseCase: getIt<GetMyRequestsUseCase>(),
      createRequestUseCase: getIt<CreateRequestUseCase>(),
      getAllZonesUseCase: getIt<GetAllZonesUseCase>(),
    ),
  );
}

/// Helper to get dependencies
///
/// Usage:
/// ```dart
/// final loginUseCase = sl<LoginUseCase>();
/// final authBloc = sl<AuthBloc>();
/// ```
T sl<T extends Object>() => getIt<T>();
