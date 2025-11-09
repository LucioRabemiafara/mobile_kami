import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../models/auth_response_model.dart';
import 'api_error_handler.dart';

/// Auth API Interface
abstract class AuthApi {
  /// Login with email and password
  Future<AuthResponseModel> login(String email, String password);

  /// Refresh access token
  Future<String> refreshToken(String refreshToken);

  /// Logout
  Future<void> logout();
}

/// Auth API Implementation
@LazySingleton(as: AuthApi)
class AuthApiImpl implements AuthApi {
  final DioClient _dioClient;

  AuthApiImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      const url_login = ApiEndpoints.login;
      print(url_login);
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );



      final res = await response.data as Map<String, dynamic>;
      final data = res["data"];
      print('response => '+ res.toString() );
//      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      return AuthResponseModel.fromJson( data );

    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['accessToken'] as String;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    }
  }
}
