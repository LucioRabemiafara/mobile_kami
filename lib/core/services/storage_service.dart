import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Service for secure storage using FlutterSecureStorage
///
/// This service handles secure storage of sensitive data like JWT tokens and user data.
/// - iOS: Uses Keychain (system-encrypted)
/// - Android: Uses EncryptedSharedPreferences (AES256)
@lazySingleton
class StorageService {
  final FlutterSecureStorage _storage;

  StorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  // ========== ACCESS TOKEN ==========

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.accessTokenKey,
        value: token,
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to save access token',
        details: e,
      );
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to read access token',
        details: e,
      );
    }
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete access token',
        details: e,
      );
    }
  }

  // ========== REFRESH TOKEN ==========

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: token,
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to save refresh token',
        details: e,
      );
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to read refresh token',
        details: e,
      );
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete refresh token',
        details: e,
      );
    }
  }

  // ========== USER DATA ==========

  /// Save user data as JSON string
  Future<void> saveUser(String userJson) async {
    try {
      print(userJson);
      await _storage.write(
        key: AppConstants.userDataKey,
        value: userJson,
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to save user data',
        details: e,
      );
    }
  }

  /// Get user data as JSON string
  Future<String?> getUser() async {
    try {
      return await _storage.read(key: AppConstants.userDataKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to read user data',
        details: e,
      );
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete user data',
        details: e,
      );
    }
  }

  // ========== UTILITY METHODS ==========

  /// Check if access token exists
  Future<bool> hasToken() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user data exists
  Future<bool> hasUser() async {
    try {
      final user = await getUser();
      return user != null && user.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data (logout)
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException(
        message: 'Failed to clear storage',
        details: e,
      );
    }
  }

  /// Save custom key-value pair
  Future<void> saveCustom(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException(
        message: 'Failed to save custom data',
        details: e,
      );
    }
  }

  /// Get custom value by key
  Future<String?> getCustom(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to read custom data',
        details: e,
      );
    }
  }

  /// Delete custom key
  Future<void> deleteCustom(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete custom data',
        details: e,
      );
    }
  }

  /// Get all stored keys
  Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw StorageException(
        message: 'Failed to read all data',
        details: e,
      );
    }
  }
}
