import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'order_model.g.dart';

/// Order model as defined in the API documentation
@JsonSerializable()
class OrderModel extends Equatable {
  final int id;
  final int userId;
  final String? customerName;
  @JsonKey(unknownEnumValue: OrderStatus.pending)
  final OrderStatus status;
  final double totalAmount;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    this.customerName,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        customerName,
        status,
        totalAmount,
        notes,
        items,
        createdAt,
        updatedAt,
      ];

  OrderModel copyWith({
    int? id,
    int? userId,
    String? customerName,
    OrderStatus? status,
    double? totalAmount,
    String? notes,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Order item model
@JsonSerializable()
class OrderItemModel extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  @override
  List<Object?> get props =>
      [id, productId, productName, quantity, price, subtotal];
}

/// Create order request
@JsonSerializable()
class CreateOrderRequest {
  final String? customerName;
  final String? notes;
  final List<CreateOrderItemRequest> items;

  const CreateOrderRequest({
    this.customerName,
    this.notes,
    required this.items,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Create order item request
@JsonSerializable()
class CreateOrderItemRequest {
  final int productId;
  final int quantity;

  const CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  factory CreateOrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderItemRequestToJson(this);
}

/// Update order status request
@JsonSerializable()
class UpdateOrderStatusRequest {
  final String status;

  const UpdateOrderStatusRequest({
    required this.status,
  });

  factory UpdateOrderStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOrderStatusRequestToJson(this);
}
