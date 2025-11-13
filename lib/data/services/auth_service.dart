import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

/// Authentication service - handles all auth-related API calls
/// Following the API documentation at docs/api/Authentication.md
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Login with username and password
  /// POST /auth/login
  Future<LoginData> login(String username, String password) async {
    try {
      AppLogger.info('Attempting login for user: $username');

      final response = await _apiClient.dio.post(
        ApiConfig.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final loginData = LoginData.fromJson(apiResponse.data!);
        AppLogger.info('Login successful for user: ${loginData.user.username}');
        return loginData;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Login failed', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get current user info
  /// GET /auth/info
  Future<UserModel> getUserInfo() async {
    try {
      AppLogger.debug('Fetching user info');

      final response = await _apiClient.dio.get(ApiConfig.authInfo);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final user = UserModel.fromJson(apiResponse.data!);
        AppLogger.debug('User info fetched: ${user.username}');
        return user;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to get user info', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Register new user
  /// POST /auth/register
  Future<UserModel> register(RegisterRequest request) async {
    try {
      AppLogger.info('Registering new user: ${request.username}');

      final response = await _apiClient.dio.post(
        ApiConfig.authRegister,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final user = UserModel.fromJson(apiResponse.data!);
        AppLogger.info('Registration successful: ${user.username}');
        return user;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Registration failed', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Change password
  /// POST /auth/change-password
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      AppLogger.info('Changing password');

      final response = await _apiClient.dio.post(
        ApiConfig.authChangePassword,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }

      AppLogger.info('Password changed successfully');
    } on DioException catch (e) {
      AppLogger.error('Failed to change password', e);
      throw ApiException.fromDioException(e);
    }
  }
}
