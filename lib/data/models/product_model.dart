import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

/// Product model as defined in the API documentation
@JsonSerializable()
class ProductModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool available;
  final int? categoryId;
  final String? categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.available,
    this.categoryId,
    this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        available,
        categoryId,
        categoryName,
        createdAt,
        updatedAt,
      ];

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? available,
    int? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Category model
@JsonSerializable()
class CategoryModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt];
}
