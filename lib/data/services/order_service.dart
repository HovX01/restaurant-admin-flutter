import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

/// Order service - handles all order-related API calls
/// Following the API documentation at docs/api/API-Reference.md
class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get paginated list of orders
  /// GET /orders?page=0&size=20&status=CONFIRMED
  Future<PagedResponse<OrderModel>> getOrders({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      AppLogger.debug('Fetching orders: page=$page, size=$size, status=$status');

      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.orders,
        queryParameters: queryParameters,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pagedResponse = PagedResponse<OrderModel>.fromJson(
          apiResponse.data!,
          (json) => OrderModel.fromJson(json as Map<String, dynamic>),
        );
        AppLogger.debug('Fetched ${pagedResponse.content.length} orders');
        return pagedResponse;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch orders', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get order by ID
  /// GET /orders/{id}
  Future<OrderModel> getOrderById(int id) async {
    try {
      AppLogger.debug('Fetching order: $id');

      final response = await _apiClient.dio.get('${ApiConfig.orders}/$id');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final order = OrderModel.fromJson(apiResponse.data!);
        AppLogger.debug('Order fetched: ${order.id}');
        return order;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch order', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new order
  /// POST /orders
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      AppLogger.info('Creating order');

      final response = await _apiClient.dio.post(
        ApiConfig.orders,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final order = OrderModel.fromJson(apiResponse.data!);
        AppLogger.info('Order created: ${order.id}');
        return order;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to create order', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Update order status
  /// PATCH /orders/{id}/status
  Future<OrderModel> updateOrderStatus(int id, String status) async {
    try {
      AppLogger.info('Updating order status: $id -> $status');

      final response = await _apiClient.dio.patch(
        '${ApiConfig.orders}/$id/status',
        data: {'status': status},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final order = OrderModel.fromJson(apiResponse.data!);
        AppLogger.info('Order status updated: ${order.id} -> ${order.status}');
        return order;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to update order status', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get kitchen orders
  /// GET /orders/kitchen
  Future<List<OrderModel>> getKitchenOrders() async {
    try {
      AppLogger.debug('Fetching kitchen orders');

      final response = await _apiClient.dio.get(ApiConfig.ordersKitchen);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final orders = apiResponse.data!
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.debug('Fetched ${orders.length} kitchen orders');
        return orders;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch kitchen orders', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete order
  /// DELETE /orders/{id}
  Future<void> deleteOrder(int id) async {
    try {
      AppLogger.info('Deleting order: $id');

      final response = await _apiClient.dio.delete('${ApiConfig.orders}/$id');

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

      AppLogger.info('Order deleted: $id');
    } on DioException catch (e) {
      AppLogger.error('Failed to delete order', e);
      throw ApiException.fromDioException(e);
    }
  }
}
