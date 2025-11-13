import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/websocket_service.dart';

/// Order provider for managing order state
class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  final WebSocketService _webSocketService;

  OrderProvider({
    OrderService? orderService,
    WebSocketService? webSocketService,
  })  : _orderService = orderService ?? OrderService(),
        _webSocketService = webSocketService ?? WebSocketService() {
    _listenToWebSocket();
  }

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 0;
  bool _hasMore = true;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// Fetch orders with pagination
  Future<void> fetchOrders({
    bool refresh = false,
    OrderStatus? status,
  }) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _orders.clear();
      }

      _setLoading(true);
      _clearError();

      final pagedResponse = await _orderService.getOrders(
        page: _currentPage,
        size: AppConstants.defaultPageSize,
        status: status?.value,
      );

      if (refresh) {
        _orders = pagedResponse.content;
      } else {
        _orders.addAll(pagedResponse.content);
      }

      _hasMore = !pagedResponse.last;
      _currentPage++;

      AppLogger.info('Fetched ${pagedResponse.content.length} orders');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch orders', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch orders error', e, stackTrace);
      _setError('Failed to load orders');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch specific order by ID
  Future<void> fetchOrderById(int id) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _orderService.getOrderById(id);
      _selectedOrder = order;

      AppLogger.info('Fetched order: ${order.id}');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch order', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch order error', e, stackTrace);
      _setError('Failed to load order');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new order
  Future<bool> createOrder(CreateOrderRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _orderService.createOrder(request);

      // Add to list
      _orders.insert(0, order);

      AppLogger.info('Order created: ${order.id}');
      return true;
    } on ApiException catch (e) {
      AppLogger.error('Failed to create order', e);
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Create order error', e, stackTrace);
      _setError('Failed to create order');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(int id, OrderStatus status) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedOrder = await _orderService.updateOrderStatus(
        id,
        status.value,
      );

      // Update in list
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      // Update selected order if it's the same
      if (_selectedOrder?.id == id) {
        _selectedOrder = updatedOrder;
      }

      AppLogger.info('Order status updated: $id -> ${status.value}');
      return true;
    } on ApiException catch (e) {
      AppLogger.error('Failed to update order status', e);
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Update order status error', e, stackTrace);
      _setError('Failed to update order status');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch kitchen orders (for kitchen staff)
  Future<void> fetchKitchenOrders() async {
    try {
      _setLoading(true);
      _clearError();

      final kitchenOrders = await _orderService.getKitchenOrders();
      _orders = kitchenOrders;

      AppLogger.info('Fetched ${kitchenOrders.length} kitchen orders');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch kitchen orders', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch kitchen orders error', e, stackTrace);
      _setError('Failed to load kitchen orders');
    } finally {
      _setLoading(false);
    }
  }

  /// Listen to WebSocket for real-time order updates
  void _listenToWebSocket() {
    // Listen to general notifications
    _webSocketService.notificationsStream.listen((data) {
      _handleWebSocketUpdate(data);
    });

    // Listen to kitchen-specific updates
    _webSocketService.kitchenStream.listen((data) {
      _handleWebSocketUpdate(data);
    });
  }

  /// Handle WebSocket updates
  void _handleWebSocketUpdate(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;

      if (type == 'ORDER_CREATED' || type == 'ORDER_UPDATED') {
        final orderData = data['data'] as Map<String, dynamic>?;
        if (orderData != null) {
          final order = OrderModel.fromJson(orderData);

          // Update or add order
          final index = _orders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            _orders[index] = order;
          } else {
            _orders.insert(0, order);
          }

          notifyListeners();
          AppLogger.info('Order updated via WebSocket: ${order.id}');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to handle WebSocket update', e, stackTrace);
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all orders
  void clear() {
    _orders.clear();
    _selectedOrder = null;
    _currentPage = 0;
    _hasMore = true;
    _clearError();
    notifyListeners();
  }
}
