import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/user_model.dart';
import '../../models/zone_model.dart';
import 'api_error_handler.dart';

/// User API Interface
abstract class UserApi {
  /// Get user by ID
  /// API Doc: GET /api/users/{id}
  Future<UserModel> getUser(int userId);

  /// Get zones accessible by user
  /// API Doc: GET /api/users/{id}/access-zones
  Future<List<ZoneModel>> getAccessZones(int userId);
}

/// User API Implementation
@LazySingleton(as: UserApi)
class UserApiImpl implements UserApi {
  final DioClient _dioClient;

  UserApiImpl(this._dioClient);

  @override
  Future<UserModel> getUser(int userId) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.getUser}/$userId');

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<List<ZoneModel>> getAccessZones(int userId) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.getUser}/$userId${ApiEndpoints.getUserAccessZones}',
      );

      // Format de réponse: { success, message, data: [...], errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      return data
          .map((json) => ZoneModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
