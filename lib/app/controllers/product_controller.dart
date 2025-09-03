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
  final _selectedCategory = ''.obs;

  // Computed values
  late final RxInt _totalProducts;
  late final RxBool _hasProducts;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isRefreshing => _isRefreshing.value;
  int get totalProducts => _totalProducts.value;
  bool get hasProducts => _products.isNotEmpty;
  String get selectedCategory => _selectedCategory.value;

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

  // Filter products by category
  void filterByCategory(String category) {
    _selectedCategory.value = category;
  }

  // Get filtered products by category
  List<Product> get filteredProducts {
    if (_selectedCategory.isNotEmpty) {
      return _products.where((product) {
        return product.category.toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }
    return _products;
  }

  // Get unique categories
  List<String> get uniqueCategories {
    return _products.map((product) => product.category).toSet().toList();
  }
}
