import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Secure storage manager for sensitive data like JWT tokens
/// Using flutter_secure_storage for platform-specific secure storage
/// - iOS: Keychain Services
/// - Android: EncryptedSharedPreferences
class SecureStorageManager {
  static final SecureStorageManager _instance = SecureStorageManager._internal();
  factory SecureStorageManager() => _instance;
  SecureStorageManager._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      AppLogger.debug('Token saved securely');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save token', e, stackTrace);
      rethrow;
    }
  }

  /// Get saved JWT token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read token', e, stackTrace);
      return null;
    }
  }

  /// Delete JWT token (on logout)
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      AppLogger.debug('Token deleted');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete token', e, stackTrace);
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    try {
      await _storage.write(key: 'user_id', value: userId.toString());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save user ID', e, stackTrace);
    }
  }

  /// Get user ID
  Future<int?> getUserId() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      return userId != null ? int.tryParse(userId) : null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read user ID', e, stackTrace);
      return null;
    }
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('All secure storage cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear storage', e, stackTrace);
    }
  }

  /// Check if JWT token is expired
  /// JWT format: header.payload.signature
  /// Payload contains exp field with Unix timestamp
  Future<bool> isTokenExpired() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return true;

      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (base64)
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Token is expired if current time is after expiration
      return now.isAfter(expirationDate);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check token expiration', e, stackTrace);
      return true; // Consider expired on error
    }
  }
}
