import 'package:get/get.dart';
import '../data/models/product.dart';
import '../data/sources/product_source.dart';

class ProductController extends GetxController {
  static ProductController get to => Get.find();

  // Observable state
  final _products = <Product>[].obs;
  final _isLoading = false.obs;
  final _error = ''.obs;
  final _isRefreshing = false.obs;

  // Computed values
  late final RxInt _totalProducts;
  late final RxBool _hasProducts;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isRefreshing => _isRefreshing.value;
  int get totalProducts => _totalProducts.value;
  bool get hasProducts => _hasProducts.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize computed values
    _totalProducts = 0.obs;
    _hasProducts = false.obs;

    // Listen to products changes
    ever(_products, _updateComputedValues);

    // Load products on initialization
    loadProducts();
  }

  void _updateComputedValues(List<Product> products) {
    _totalProducts.value = products.length;
    _hasProducts.value = products.isNotEmpty;
  }

  Future<void> loadProducts() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final products = await ProductSource.loadProducts();
      _products.value = products;

      // Log success
      Get.log('Loaded ${products.length} products successfully');
    } catch (e) {
      _error.value = 'Failed to load products: $e';
      Get.log('Error loading products: $e', isError: true);

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to load products. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    if (_isRefreshing.value) return; // Prevent multiple refresh calls

    try {
      _isRefreshing.value = true;
      _error.value = '';

      final products = await ProductSource.loadProducts();
      _products.value = products;

      // Show success feedback
      Get.snackbar(
        'Refreshed',
        'Products updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      _error.value = 'Failed to refresh products: $e';
      Get.log('Error refreshing products: $e', isError: true);
    } finally {
      _isRefreshing.value = false;
    }
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      Get.log('Product with ID $id not found', isError: true);
      return null;
    }
  }

  // Search products by name or category
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter products by category
  List<Product> getProductsByCategory(String category) {
    if (category.isEmpty) return _products;

    return _products
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Get unique categories
  List<String> get uniqueCategories {
    return _products.map((product) => product.category).toSet().toList();
  }

  // Get products in price range
  List<Product> getProductsInPriceRange(double minPrice, double maxPrice) {
    return _products
        .where(
          (product) => product.price >= minPrice && product.price <= maxPrice,
        )
        .toList();
  }

  // Sort products
  void sortProducts(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.nameAsc:
        _products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        _products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.priceAsc:
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        _products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        _products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    _products.refresh();
  }

  // Get product statistics
  Map<String, dynamic> getProductStats() {
    if (_products.isEmpty) return {};

    final prices = _products.map((p) => p.price).toList();
    final ratings = _products.map((p) => p.rating).toList();

    return {
      'totalProducts': _products.length,
      'averagePrice': prices.reduce((a, b) => a + b) / prices.length,
      'minPrice': prices.reduce((a, b) => a < b ? a : b),
      'maxPrice': prices.reduce((a, b) => a > b ? a : b),
      'averageRating': ratings.reduce((a, b) => a + b) / ratings.length,
      'categories': uniqueCategories.length,
    };
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

enum SortOption { nameAsc, nameDesc, priceAsc, priceDesc, ratingDesc }
