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
      print('🔍 [UserAPI] Fetching access zones for userId: $userId');
      final url = '${ApiEndpoints.getUser}/$userId${ApiEndpoints.getUserAccessZones}';
      print('🔍 [UserAPI] URL: $url');

      final response = await _dioClient.get(url);

      // Format de réponse: { success, message, data: [...], errors, timestamp }
      print('🔍 [UserAPI] Raw response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;
      print('✅ [UserAPI] Zones count: ${data.length}');

      final zones = data
          .map((json) => ZoneModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ [UserAPI] Parsed zones: ${zones.map((z) => z.name).join(", ")}');
      return zones;
    } on DioException catch (e) {
      print('❌ [UserAPI] DioException: ${e.message}');
      throw ApiErrorHandler.handleDioException(e);
    } catch (e, stackTrace) {
      print('❌ [UserAPI] Unexpected error: $e');
      print('❌ [UserAPI] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
