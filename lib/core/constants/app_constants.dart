/// Application Constants
class AppConstants {
  // App Information
  static const String appName = 'Restaurant Admin';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyRememberMe = 'remember_me';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration normalCache = Duration(minutes: 15);
  static const Duration longCache = Duration(hours: 1);
}

/// User Roles as defined in the API documentation
enum UserRole {
  admin('ADMIN'),
  manager('MANAGER'),
  kitchenStaff('KITCHEN_STAFF'),
  deliveryStaff('DELIVERY_STAFF');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid user role: $value'),
    );
  }
}

/// Order Status as defined in the API documentation
enum OrderStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  preparing('PREPARING'),
  ready('READY'),
  delivering('DELIVERING'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Delivery Status as defined in the API documentation
enum DeliveryStatus {
  pending('PENDING'),
  assigned('ASSIGNED'),
  pickedUp('PICKED_UP'),
  inTransit('IN_TRANSIT'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  final String value;
  const DeliveryStatus(this.value);

  static DeliveryStatus fromString(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeliveryStatus.pending,
    );
  }
}
