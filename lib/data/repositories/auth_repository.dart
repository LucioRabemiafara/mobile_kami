import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../data_sources/remote/auth_api.dart';
import '../models/user_model.dart';

/// Auth Repository Interface
abstract class AuthRepository {
  /// Login with email and password
  /// Returns Either<Failure, UserModel>
  Future<Either<Failure, UserModel>> login(String email, String password);

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Get cached user from storage
  Future<Either<Failure, UserModel?>> getCachedUser();

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();
}

/// Auth Repository Implementation
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final StorageService _storageService;

  AuthRepositoryImpl(this._authApi, this._storageService);

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      // Call API
      print('Part 1');
      final authResponse = await _authApi.login(email, password);

      print('Part2');
      // Store tokens
      await _storageService.saveAccessToken(authResponse.accessToken);
      print('Part 3');
      await _storageService.saveRefreshToken(authResponse.refreshToken);
      print('Part 4');
      // Store user as JSON
      final userJson = jsonEncode(authResponse.user.toJson());
      await _storageService.saveUser(userJson);

      return Right(authResponse.user);

    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } catch (e,stackTrace) {
      print('Erreur: $e\n$stackTrace');
//      debugPrintStack(label: 'Erreur: $e');
      return Left(GenericFailure(message: 'Une erreur inattendue est survenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call API (may fail but we don't care)
      try {
        await _authApi.logout();
      } catch (e) {
        // Ignore API errors during logout
      }

      // Clear local storage
      await _storageService.clear();

      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Erreur lors de la déconnexion'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCachedUser() async {
    try {
      final userJson = await _storageService.getUser();

      if (userJson == null || userJson.isEmpty) {
        return const Right(null);
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      return Right(user);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Erreur lors de la lecture des données utilisateur'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _storageService.hasToken();
    } catch (e) {
      return false;
    }
  }
}
