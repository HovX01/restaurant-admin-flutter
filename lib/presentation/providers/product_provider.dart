import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';

/// Product provider for managing product state
class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 0;
  bool _hasMore = true;

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// Fetch products with pagination
  Future<void> fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _products.clear();
      }

      _setLoading(true);
      _clearError();

      final pagedResponse = await _productService.getProducts(
        page: _currentPage,
        size: AppConstants.defaultPageSize,
      );

      if (refresh) {
        _products = pagedResponse.content;
      } else {
        _products.addAll(pagedResponse.content);
      }

      _hasMore = !pagedResponse.last;
      _currentPage++;

      AppLogger.info('Fetched ${pagedResponse.content.length} products');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch products', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch products error', e, stackTrace);
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch only available products
  Future<void> fetchAvailableProducts() async {
    try {
      _setLoading(true);
      _clearError();

      _products = await _productService.getAvailableProducts();

      AppLogger.info('Fetched ${_products.length} available products');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch available products', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch available products error', e, stackTrace);
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch categories
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      _clearError();

      _categories = await _productService.getCategories();

      AppLogger.info('Fetched ${_categories.length} categories');
    } on ApiException catch (e) {
      AppLogger.error('Failed to fetch categories', e);
      _setError(e.message);
    } catch (e, stackTrace) {
      AppLogger.error('Fetch categories error', e, stackTrace);
      _setError('Failed to load categories');
    } finally {
      _setLoading(false);
    }
  }

  /// Get products by category
  List<ProductModel> getProductsByCategory(int categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  /// Get available products only
  List<ProductModel> getAvailableProductsList() {
    return _products.where((p) => p.available).toList();
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

  /// Clear all products
  void clear() {
    _products.clear();
    _categories.clear();
    _currentPage = 0;
    _hasMore = true;
    _clearError();
    notifyListeners();
  }
}
