import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'delivery_model.g.dart';

/// Delivery model as defined in the API documentation
@JsonSerializable()
class DeliveryModel extends Equatable {
  final int id;
  final int orderId;
  final int? driverId;
  final String? driverName;
  @JsonKey(unknownEnumValue: DeliveryStatus.pending)
  final DeliveryStatus status;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? notes;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    this.driverId,
    this.driverName,
    required this.status,
    this.deliveryAddress,
    this.customerPhone,
    this.notes,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        orderId,
        driverId,
        driverName,
        status,
        deliveryAddress,
        customerPhone,
        notes,
        estimatedDeliveryTime,
        actualDeliveryTime,
        createdAt,
        updatedAt,
      ];

  DeliveryModel copyWith({
    int? id,
    int? orderId,
    int? driverId,
    String? driverName,
    DeliveryStatus? status,
    String? deliveryAddress,
    String? customerPhone,
    String? notes,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create delivery request
@JsonSerializable()
class CreateDeliveryRequest {
  final int orderId;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? notes;
  final DateTime? estimatedDeliveryTime;

  const CreateDeliveryRequest({
    required this.orderId,
    this.deliveryAddress,
    this.customerPhone,
    this.notes,
    this.estimatedDeliveryTime,
  });

  factory CreateDeliveryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDeliveryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDeliveryRequestToJson(this);
}

/// Update delivery status request
@JsonSerializable()
class UpdateDeliveryStatusRequest {
  final String status;

  const UpdateDeliveryStatusRequest({
    required this.status,
  });

  factory UpdateDeliveryStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDeliveryStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDeliveryStatusRequestToJson(this);
}

/// Assign driver request
@JsonSerializable()
class AssignDriverRequest {
  final int driverId;

  const AssignDriverRequest({
    required this.driverId,
  });

  factory AssignDriverRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignDriverRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignDriverRequestToJson(this);
}
