/// API Configuration for Restaurant Admin System
/// Following the documentation at docs/api/README.md
class ApiConfig {
  // Base URLs - Update these for production
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String wsUrl = 'ws://10.0.2.2:8080/ws';

  // Timeout configuration
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // WebSocket Topics
  static const String wsTopicNotifications = '/topic/notifications';
  static const String wsTopicKitchen = '/topic/kitchen';
  static const String wsTopicDeliveryStaff = '/topic/delivery-staff';
  static const String wsTopicSystem = '/topic/system';

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authInfo = '/auth/info';
  static const String authChangePassword = '/auth/change-password';

  static const String products = '/products';
  static const String productsAvailable = '/products/available';

  static const String orders = '/orders';
  static const String ordersKitchen = '/orders/kitchen';
  static const String ordersStats = '/orders/stats';

  static const String deliveries = '/deliveries';
  static const String deliveriesMy = '/deliveries/my';
  static const String deliveriesStats = '/deliveries/stats';

  static const String categories = '/categories';
  static const String users = '/users';

  // Default test credentials from documentation
  static const Map<String, Map<String, String>> testAccounts = {
    'admin': {
      'username': 'admin',
      'password': 'password123',
      'role': 'ADMIN',
    },
    'manager': {
      'username': 'manager',
      'password': 'password123',
      'role': 'MANAGER',
    },
    'kitchen': {
      'username': 'kitchen',
      'password': 'password123',
      'role': 'KITCHEN_STAFF',
    },
    'driver': {
      'username': 'driver',
      'password': 'password123',
      'role': 'DELIVERY_STAFF',
    },
  };
}
