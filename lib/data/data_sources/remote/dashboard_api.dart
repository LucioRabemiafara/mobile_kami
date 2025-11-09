import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/dashboard_kpis_model.dart';
import 'api_error_handler.dart';

/// Dashboard API Interface
abstract class DashboardApi {
  /// Get KPIs for dashboard
  /// API Doc: GET /api/dashboard/kpis
  Future<DashboardKpisModel> getKpis();
}

/// Dashboard API Implementation
@LazySingleton(as: DashboardApi)
class DashboardApiImpl implements DashboardApi {
  final DioClient _dioClient;

  DashboardApiImpl(this._dioClient);

  @override
  Future<DashboardKpisModel> getKpis() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.dashboardKpis,
      );

      // Format de réponse: { success, message, data: {...}, errors, timestamp }
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return DashboardKpisModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
