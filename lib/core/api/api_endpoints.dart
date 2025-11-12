import './../constants/app_constants.dart';
/// API Endpoints
///
/// All API endpoint URLs organized by feature
class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  // Base URL   192.168.88.26
  //  192.168.88.28
  static const String baseUrl = 'http://192.168.143.222:8080/api';

  // ========== AUTHENTICATION ==========

  /// POST /auth/login
  /// Body: { email, password }
  /// Response: { accessToken, refreshToken, user }
  static const String login = baseUrl + AppConstants.loginEndpoint; // '/auth/login'  ;

  /// POST /auth/refresh
  /// Body: { refreshToken }
  /// Response: { accessToken }
  static const String refresh =baseUrl + AppConstants.refreshEndpoint; //'/auth/refresh';

  /// POST /auth/logout
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { message }
  static const String logout = baseUrl + AppConstants.logoutEndpoint; // '/auth/logout';

  // ========== ACCESS CONTROL ==========

  /// POST /access/verify
  /// Body: { user_id, qr_code, device_unlocked }
  /// Response: { status: GRANTED|PENDING_PIN|DENIED, zone, tempToken?, reason? }
  static const String verifyAccess = baseUrl + AppConstants.verifyAccessEndpoint; //'/access/verify';

  /// POST /access/verify-pin
  /// Body: { user_id, temp_token, pin_code }
  /// Response: { status: GRANTED|DENIED, zone, reason?, attemptsRemaining? }
  static const String verifyPin = baseUrl + AppConstants.verifyPinEndpoint;//'/access/verify-pin';

  /// GET /access/history?userId={id}&dateStart={start}&dateEnd={end}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: [{ id, zone, timestamp, status, method, reason? }]
  static const String accessHistory = baseUrl + AppConstants.accessHistoryEndpoint;// '/access/history';

  // ========== ATTENDANCE (POINTAGE) ==========

  /// POST /attendance/check-in
  /// Body: { user_id, qr_code, pin_code, device_unlocked }
  /// Response: { checkIn, isLate }
  static const String checkIn = baseUrl + AppConstants.checkInEndpoint; //'/attendance/check-in';

  /// POST /attendance/check-out
  /// Body: { user_id, qr_code, pin_code, device_unlocked }
  /// Response: { checkOut, hoursWorked }
  static const String checkOut = baseUrl + AppConstants.checkOutEndpoint; // '/attendance/check-out';

  /// GET /attendance/today?userId={id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { checkIn?, checkOut?, isLate?, hoursWorked? }
  static const String attendanceToday = baseUrl + AppConstants.attendanceTodayEndpoint; //'/attendance/today';

  /// GET /attendance/history?userId={id}&month={yyyy-MM}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: [{ date, checkIn, checkOut, hoursWorked, isLate }]
  static const String attendanceHistory = baseUrl + AppConstants.attendanceHistoryEndpoint; //'/attendance/history';

  /// GET /attendance/stats?userId={id}&month={month}&year={year}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { totalDaysWorked, totalHoursWorked, averageHoursPerDay, totalLateArrivals }
  static const String attendanceStats = baseUrl + '/attendance/stats';

  // ========== USERS ==========

  /// GET /users/{id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { id, email, firstName, lastName, posts, department, ... }
  static const String getUser = baseUrl + AppConstants.usersEndpoint;// '/users';

  /// GET /users/{id}/access-zones
  /// Headers: Authorization Bearer {accessToken}
  /// Response: [{ zone, reason: VIA_POST|TEMPORARY_PERMISSION, post?, validUntil? }]
  static const String getUserAccessZones = AppConstants.accessZonesEndpoint ;// '/access-zones';

  // ========== ACCESS REQUESTS ==========

  /// GET /access-requests/my-requests?userId={id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: [{ id, zone, dateStart, dateEnd, justification, status, ... }]
  static const String myAccessRequests = baseUrl + AppConstants.myRequestsEndpoint; //'/access-requests/my-requests';

  /// POST /access-requests
  /// Body: { userId, zoneId, dateStart, dateEnd, justification }
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { id, status, createdAt }
  static const String createAccessRequest = baseUrl + '/access-requests';

  /// GET /access-requests/{id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { id, zone, dateStart, dateEnd, justification, status, ... }
  static const String getAccessRequest = baseUrl + '/access-requests';

  // ========== DASHBOARD ==========

  /// GET /dashboard/kpis?userId={id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: {
  ///   hoursThisMonth,
  ///   accessibleZonesCount,
  ///   accessTodayCount,
  ///   hasCheckedInToday,
  ///   last7DaysHours: [{ date, hours }]
  /// }
  static const String dashboardKpis = baseUrl + '/dashboard/kpis';

  // ========== ZONES ==========

  /// GET /zones/{id}
  /// Headers: Authorization Bearer {accessToken}
  /// Response: { id, name, building, floor, securityLevel, allowedPosts, ... }
  static const String getZone = baseUrl + '/zones';

  /// GET /zones
  /// Headers: Authorization Bearer {accessToken}
  /// Response: [{ id, name, building, floor, securityLevel, ... }]
  static const String getAllZones = baseUrl + '/zones';

  // ========== UTILITY METHODS ==========

  /// Build full URL with base URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Build URL with path parameters
  /// Example: buildUrlWithParams('/users/{id}', {'id': '123'})
  /// Returns: 'http://localhost:8080/api/users/123'
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return '$baseUrl$url';
  }

  /// Build URL with query parameters
  /// Example: buildUrlWithQuery('/access/history', {'userId': '123', 'dateStart': '2024-01-01'})
  /// Returns: 'http://localhost:8080/api/access/history?userId=123&dateStart=2024-01-01'
  static String buildUrlWithQuery(String endpoint, Map<String, dynamic> queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    final newUri = uri.replace(queryParameters: queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
    return newUri.toString();
  }
}
