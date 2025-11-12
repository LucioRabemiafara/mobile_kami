import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/attendance_model.dart';
import '../../models/attendance_stats_model.dart';
import 'api_error_handler.dart';

/// Attendance API Interface
abstract class AttendanceApi {
  /// Check in (pointer arrivée)
  /// API Doc: POST /api/attendance/check-in
  Future<AttendanceModel> checkIn({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkInTime,
    String? location,
  });

  /// Check out (pointer départ)
  /// API Doc: POST /api/attendance/check-out
  Future<AttendanceModel> checkOut({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkOutTime,
    String? location,
  });

  /// Get today's attendance (returns null if not found - 404)
  /// API Doc: GET /api/attendance/today?userId={id}
  Future<AttendanceModel?> getAttendanceToday({
    required int userId,
  });

  /// Get attendance history
  /// API Doc: GET /api/attendance/history?userId={id}&startDate={date}&endDate={date}
  Future<List<AttendanceModel>> getAttendanceHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get monthly attendance statistics
  /// API Doc: GET /api/attendance/stats?userId={id}&month={month}&year={year}
  Future<AttendanceStatsModel> getAttendanceStats({
    required int userId,
    int? month,
    int? year,
  });
}

/// Attendance API Implementation
@LazySingleton(as: AttendanceApi)
class AttendanceApiImpl implements AttendanceApi {
  final DioClient _dioClient;

  AttendanceApiImpl(this._dioClient);

  @override
  Future<AttendanceModel> checkIn({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkInTime,
    String? location,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.checkIn,
        data: {
          'userId': userId,  // Conforme à API doc
          'qrCode': qrCode,  // Conforme à API doc
          'pinCode': pinCode,  // Conforme à API doc
          'checkInTime': checkInTime.toIso8601String(),  // Conforme à API doc
          if (location != null) 'location': location,
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AttendanceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<AttendanceModel> checkOut({
    required int userId,
    required String qrCode,
    required String pinCode,
    required DateTime checkOutTime,
    String? location,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.checkOut,
        data: {
          'userId': userId,  // Conforme à API doc
          'qrCode': qrCode,  // Conforme à API doc
          'pinCode': pinCode,  // Conforme à API doc
          'checkOutTime': checkOutTime.toIso8601String(),  // Conforme à API doc
          if (location != null) 'location': location,
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AttendanceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<AttendanceModel?> getAttendanceToday({
    required int userId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.attendanceToday,
        queryParameters: {
          'userId': userId,
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      return data != null ? AttendanceModel.fromJson(data) : null;
    } on DioException catch (e) {
      // Return null if not found (404)
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiErrorHandler.handleDioException(e);
    } on NotFoundException {
      // Return null if not found
      return null;
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };

      // Format ISO Date selon API doc (YYYY-MM-DD)
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.get(
        ApiEndpoints.attendanceHistory,
        queryParameters: queryParams,
      );

      // Format de réponse: { success, message, data: [...], errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      return data
          .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<AttendanceStatsModel> getAttendanceStats({
    required int userId,
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };

      if (month != null) {
        queryParams['month'] = month;
      }
      if (year != null) {
        queryParams['year'] = year;
      }

      final response = await _dioClient.get(
        ApiEndpoints.attendanceStats,
        queryParameters: queryParams,
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AttendanceStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
