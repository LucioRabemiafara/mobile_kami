/// Application Constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Development Mode
  /// ⚠️ IMPORTANT: Set to FALSE in production!
  /// When true, allows bypassing device unlock for testing on emulators
  static const bool isDevelopmentMode = true;

  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String verifyAccessEndpoint = '/access/verify';
  static const String verifyPinEndpoint = '/access/verify-pin';
  static const String accessHistoryEndpoint = '/access/history';
  static const String checkInEndpoint = '/attendance/check-in';
  static const String checkOutEndpoint = '/attendance/check-out';
  static const String attendanceTodayEndpoint = '/attendance/today';
  static const String attendanceHistoryEndpoint = '/attendance/history';
  static const String dashboardKpisEndpoint = '/dashboard/kpis';
  static const String usersEndpoint = '/users';
  static const String accessZonesEndpoint = '/access-zones';
  static const String accessRequestsEndpoint = '/access-requests';
  static const String myRequestsEndpoint = '/access-requests/my-requests';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Security Configuration
  static const int pinLength = 4;
  static const int maxPinAttempts = 3;
  static const Duration accountLockDuration = Duration(minutes: 30);
  static const Duration tempTokenValidity = Duration(minutes: 5);

  // Attendance Configuration
  static const Duration lateThreshold = Duration(hours: 9);
  static const String attendanceTimeFormat = 'HH:mm';
  static const String attendanceDateFormat = 'yyyy-MM-dd';

  // Posts (MULTI-POSTES)
  static const List<String> availablePosts = [
    'DEVELOPER',
    'DEVOPS',
    'SECURITY_AGENT',
    'HR_MANAGER',
    'ACCOUNTANT',
    'IT_SUPPORT',
    'MANAGER',
    'RECEPTIONIST',
    'MAINTENANCE',
    'EXECUTIVE',
  ];

  // Security Levels
  static const String securityLevelLow = 'LOW';
  static const String securityLevelMedium = 'MEDIUM';
  static const String securityLevelHigh = 'HIGH';

  static const List<String> securityLevels = [
    securityLevelLow,
    securityLevelMedium,
    securityLevelHigh,
  ];

  // Access Status
  static const String accessStatusGranted = 'GRANTED';
  static const String accessStatusPendingPin = 'PENDING_PIN';
  static const String accessStatusDenied = 'DENIED';

  // Access Request Status
  static const String requestStatusPending = 'PENDING';
  static const String requestStatusApproved = 'APPROVED';
  static const String requestStatusRejected = 'REJECTED';

  // UI Configuration
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration autoNavigationDelay = Duration(seconds: 3);
  static const Duration pinAutoSubmitDelay = Duration(milliseconds: 300);

  // Validation
  static const int minJustificationLength = 20;
  static const int maxJustificationLength = 500;

  // Pagination
  static const int defaultPageSize = 20;

  // Messages
  static const String defaultErrorMessage = 'Une erreur est survenue. Veuillez r\u00e9essayer.';
  static const String networkErrorMessage = 'Pas de connexion internet.';
  static const String unauthorizedMessage = 'Session expir\u00e9e. Veuillez vous reconnecter.';
}
