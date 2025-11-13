import 'package:dio/dio.dart';

/// Custom API exception for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    String message = 'An unexpected error occurred';
    int? statusCode;
    dynamic data;

    if (error.response != null) {
      statusCode = error.response?.statusCode;
      data = error.response?.data;

      // Try to extract message from API response
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      }

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          message = 'Invalid request: $message';
          break;
        case 401:
          message = 'Unauthorized. Please login again.';
          break;
        case 403:
          message = 'Forbidden. You don\'t have permission to perform this action.';
          break;
        case 404:
          message = 'Resource not found.';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
      }
    } else {
      // Handle network errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badCertificate:
          message = 'Certificate verification failed.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection. Please check your network.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = 'Network error: ${error.message}';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => message;
}
