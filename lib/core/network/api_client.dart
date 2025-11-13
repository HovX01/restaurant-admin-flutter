import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/secure_storage_manager.dart';
import '../utils/logger.dart';

/// Dio-based API client with authentication interceptor
/// Following best practices from the documentation
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initializeDio();
  }

  late final Dio _dio;
  final _storage = SecureStorageManager();

  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  /// Authentication interceptor - adds JWT token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth for login/register endpoints
        if (options.path.contains('/auth/login') ||
            options.path.contains('/auth/register')) {
          return handler.next(options);
        }

        // Add Bearer token if available
        final token = await _storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          AppLogger.debug('Added auth token to request: ${options.path}');
        }

        return handler.next(options);
      },
    );
  }

  /// Logging interceptor - logs requests and responses
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.debug(
          'REQUEST[${options.method}] => PATH: ${options.path}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.debug(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
          'Data: ${response.data}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}\n'
          'Error: ${error.message}\n'
          'Data: ${error.response?.data}',
        );
        return handler.next(error);
      },
    );
  }

  /// Error interceptor - handles common errors
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired or invalid
        if (error.response?.statusCode == 401) {
          AppLogger.warning('Received 401 - Token expired or invalid');
          await _storage.clearAll();
          // You could trigger a logout event here
        }

        // Handle 403 Forbidden
        if (error.response?.statusCode == 403) {
          AppLogger.warning('Received 403 - Insufficient permissions');
        }

        // Handle network errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          AppLogger.error('Network timeout error');
        }

        if (error.type == DioExceptionType.unknown) {
          AppLogger.error('Network connection error');
        }

        return handler.next(error);
      },
    );
  }

  /// Set base URL (useful for switching between dev/prod)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    AppLogger.info('Base URL changed to: $baseUrl');
  }

  /// Clear authorization token
  void clearAuth() {
    _dio.options.headers.remove('Authorization');
  }
}
