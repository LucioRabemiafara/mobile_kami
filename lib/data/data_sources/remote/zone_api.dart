import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/zone_model.dart';
import 'api_error_handler.dart';

/// Zone API Interface
abstract class ZoneApi {
  /// Get all zones
  /// API Doc: GET /api/zones
  Future<List<ZoneModel>> getAllZones();
}

/// Zone API Implementation
@LazySingleton(as: ZoneApi)
class ZoneApiImpl implements ZoneApi {
  final DioClient _dioClient;

  ZoneApiImpl(this._dioClient);

  @override
  Future<List<ZoneModel>> getAllZones() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getAllZones,
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
