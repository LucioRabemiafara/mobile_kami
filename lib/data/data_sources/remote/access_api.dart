import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/access_verify_response_model.dart';
import '../../models/access_event_model.dart';
import 'api_error_handler.dart';

/// Access API Interface
abstract class AccessApi {
  /// Verify access to a zone
  ///
  /// ⭐ IMPORTANT: deviceUnlocked must be true (native phone unlock verified)
  /// API Doc: POST /api/access/verify
  Future<AccessVerifyResponseModel> verifyAccess({
    required int userId,
    required String qrCode,
    String? deviceInfo,
    String? ipAddress,
  });

  /// Verify PIN for high security zones
  /// API Doc: POST /api/access/verify-pin
  Future<AccessVerifyResponseModel> verifyPin({
    required int userId,
    required String pinCode,
    required int eventId,
  });

  /// Get access history for a user
  /// API Doc: GET /api/access/history?userId={id}&dateStart={date}&dateEnd={date}
  Future<List<AccessEventModel>> getAccessHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Access API Implementation
@LazySingleton(as: AccessApi)
class AccessApiImpl implements AccessApi {
  final DioClient _dioClient;

  AccessApiImpl(this._dioClient);

  @override
  Future<AccessVerifyResponseModel> verifyAccess({
    required int userId,
    required String qrCode,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.verifyAccess,
        data: {
          'userId': userId,  // Conforme à API doc
          'qrCode': qrCode,  // Conforme à API doc
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
          if (ipAddress != null) 'ipAddress': ipAddress,
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AccessVerifyResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<AccessVerifyResponseModel> verifyPin({
    required int userId,
    required String pinCode,
    required int eventId,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.verifyPin,
        data: {
          'userId': userId,  // Conforme à API doc
          'pinCode': pinCode,  // Conforme à API doc
          'eventId': eventId,  // Conforme à API doc
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AccessVerifyResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<List<AccessEventModel>> getAccessHistory({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };

      // Format ISO DateTime complet selon API doc
      if (startDate != null) {
        queryParams['dateStart'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['dateEnd'] = endDate.toIso8601String();
      }

      final response = await _dioClient.get(
        ApiEndpoints.accessHistory,
        queryParameters: queryParams,
      );

      // Format de réponse: { success, message, data: [...], errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      return data
          .map((json) => AccessEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
