import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';
import '../models/api_response.dart';
import '../models/product_model.dart';

/// Product service - handles all product-related API calls
class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get paginated list of products
  /// GET /products?page=0&size=20
  Future<PagedResponse<ProductModel>> getProducts({
    int page = 0,
    int size = 20,
  }) async {
    try {
      AppLogger.debug('Fetching products: page=$page, size=$size');

      final response = await _apiClient.dio.get(
        ApiConfig.products,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pagedResponse = PagedResponse<ProductModel>.fromJson(
          apiResponse.data!,
          (json) => ProductModel.fromJson(json as Map<String, dynamic>),
        );
        AppLogger.debug('Fetched ${pagedResponse.content.length} products');
        return pagedResponse;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch products', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get only available products
  /// GET /products/available
  Future<List<ProductModel>> getAvailableProducts() async {
    try {
      AppLogger.debug('Fetching available products');

      final response =
          await _apiClient.dio.get(ApiConfig.productsAvailable);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final products = apiResponse.data!
            .map((json) =>
                ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.debug('Fetched ${products.length} available products');
        return products;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch available products', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get product by ID
  /// GET /products/{id}
  Future<ProductModel> getProductById(int id) async {
    try {
      AppLogger.debug('Fetching product: $id');

      final response = await _apiClient.dio.get('${ApiConfig.products}/$id');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final product = ProductModel.fromJson(apiResponse.data!);
        AppLogger.debug('Product fetched: ${product.name}');
        return product;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch product', e);
      throw ApiException.fromDioException(e);
    }
  }

  /// Get categories
  /// GET /categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      AppLogger.debug('Fetching categories');

      final response = await _apiClient.dio.get(ApiConfig.categories);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final categories = apiResponse.data!
            .map((json) =>
                CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.debug('Fetched ${categories.length} categories');
        return categories;
      } else {
        throw ApiException(
          message: apiResponse.message,
          data: apiResponse.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch categories', e);
      throw ApiException.fromDioException(e);
    }
  }
}
