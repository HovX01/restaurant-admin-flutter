import 'package:json_annotation/json_annotation.dart';

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
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MANAGER')
  manager,
  @JsonValue('KITCHEN_STAFF')
  kitchenStaff,
  @JsonValue('DELIVERY_STAFF')
  deliveryStaff;

  const UserRole();

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.kitchenStaff:
        return 'KITCHEN_STAFF';
      case UserRole.deliveryStaff:
        return 'DELIVERY_STAFF';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid user role: $value'),
    );
  }
}

/// Order Status as defined in the API documentation
enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('PREPARING')
  preparing,
  @JsonValue('READY')
  ready,
  @JsonValue('DELIVERING')
  delivering,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled;

  const OrderStatus();

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.delivering:
        return 'DELIVERING';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Delivery Status as defined in the API documentation
enum DeliveryStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ASSIGNED')
  assigned,
  @JsonValue('PICKED_UP')
  pickedUp,
  @JsonValue('IN_TRANSIT')
  inTransit,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled;

  const DeliveryStatus();

  String get value {
    switch (this) {
      case DeliveryStatus.pending:
        return 'PENDING';
      case DeliveryStatus.assigned:
        return 'ASSIGNED';
      case DeliveryStatus.pickedUp:
        return 'PICKED_UP';
      case DeliveryStatus.inTransit:
        return 'IN_TRANSIT';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static DeliveryStatus fromString(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeliveryStatus.pending,
    );
  }
}
