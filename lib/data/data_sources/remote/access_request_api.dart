import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/access_request_model.dart';
import 'api_error_handler.dart';

/// Access Request API Interface
abstract class AccessRequestApi {
  /// Get all access requests for a user
  /// API Doc: GET /api/access-requests/my-requests?userId={id}
  Future<List<AccessRequestModel>> getMyRequests(int userId);

  /// Create a new access request
  /// API Doc: POST /api/access-requests
  Future<AccessRequestModel> createRequest({
    required int userId,
    required int zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  });
}

/// Access Request API Implementation
@LazySingleton(as: AccessRequestApi)
class AccessRequestApiImpl implements AccessRequestApi {
  final DioClient _dioClient;

  AccessRequestApiImpl(this._dioClient);

  @override
  Future<List<AccessRequestModel>> getMyRequests(int userId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.myAccessRequests,
        queryParameters: {
          'userId': userId,
        },
      );

      // Format de réponse: { success, message, data: [...], errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      return data
          .map((json) => AccessRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<AccessRequestModel> createRequest({
    required int userId,
    required int zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createAccessRequest,
        data: {
          'userId': userId,
          'zoneId': zoneId,
          'startDate': startDate.toIso8601String(),  // Format ISO DateTime complet
          'endDate': endDate.toIso8601String(),  // Format ISO DateTime complet
          'justification': justification,
        },
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return AccessRequestModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
