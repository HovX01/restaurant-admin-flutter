// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryModel _$DeliveryModelFromJson(Map<String, dynamic> json) =>
    DeliveryModel(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      driverId: json['driverId'] as int?,
      driverName: json['driverName'] as String?,
      status: $enumDecode(_$DeliveryStatusEnumMap, json['status'],
          unknownValue: DeliveryStatus.pending),
      deliveryAddress: json['deliveryAddress'] as String?,
      customerPhone: json['customerPhone'] as String?,
      notes: json['notes'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
      actualDeliveryTime: json['actualDeliveryTime'] == null
          ? null
          : DateTime.parse(json['actualDeliveryTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DeliveryModelToJson(DeliveryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'status': _$DeliveryStatusEnumMap[instance.status]!,
      'deliveryAddress': instance.deliveryAddress,
      'customerPhone': instance.customerPhone,
      'notes': instance.notes,
      'estimatedDeliveryTime':
          instance.estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': instance.actualDeliveryTime?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.pending: 'PENDING',
  DeliveryStatus.assigned: 'ASSIGNED',
  DeliveryStatus.pickedUp: 'PICKED_UP',
  DeliveryStatus.inTransit: 'IN_TRANSIT',
  DeliveryStatus.delivered: 'DELIVERED',
  DeliveryStatus.cancelled: 'CANCELLED',
};

CreateDeliveryRequest _$CreateDeliveryRequestFromJson(
        Map<String, dynamic> json) =>
    CreateDeliveryRequest(
      orderId: json['orderId'] as int,
      deliveryAddress: json['deliveryAddress'] as String?,
      customerPhone: json['customerPhone'] as String?,
      notes: json['notes'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
    );

Map<String, dynamic> _$CreateDeliveryRequestToJson(
        CreateDeliveryRequest instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'deliveryAddress': instance.deliveryAddress,
      'customerPhone': instance.customerPhone,
      'notes': instance.notes,
      'estimatedDeliveryTime':
          instance.estimatedDeliveryTime?.toIso8601String(),
    };

UpdateDeliveryStatusRequest _$UpdateDeliveryStatusRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateDeliveryStatusRequest(
      status: json['status'] as String,
    );

Map<String, dynamic> _$UpdateDeliveryStatusRequestToJson(
        UpdateDeliveryStatusRequest instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

AssignDriverRequest _$AssignDriverRequestFromJson(
        Map<String, dynamic> json) =>
    AssignDriverRequest(
      driverId: json['driverId'] as int,
    );

Map<String, dynamic> _$AssignDriverRequestToJson(
        AssignDriverRequest instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
    };

K $enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}
