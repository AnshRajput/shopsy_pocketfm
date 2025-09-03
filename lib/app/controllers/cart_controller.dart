import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../data/models/product.dart';
import '../data/models/cart_item.dart';

// Mock storage for when SharedPreferences is not available
class MockStorage {
  dynamic read(String key) => null;
  void write(String key, dynamic value) {}
  void remove(String key) {}
}

class CartController extends GetxController {
  static CartController get to => Get.find();

  // Storage instance for cart persistence
  dynamic _storage = MockStorage();
  static const String _storageKey = 'cart_items';
  bool _isStorageInitialized = false;

  // Observable cart items with better performance
  final _cartItems = <CartItem>[].obs;

  // Computed values for better performance
  late final RxInt _itemCount;
  late final RxDouble _totalPrice;
  late final RxBool _isEmpty;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  int get itemCount => _itemCount.value;
  double get totalPrice => _totalPrice.value;
  bool get isEmpty => _isEmpty.value;
  bool get isStorageInitialized => _isStorageInitialized;

  @override
  void onInit() {
    super.onInit();

    // Initialize computed values first
    _itemCount = 0.obs;
    _totalPrice = 0.0.obs;
    _isEmpty = true.obs;

    // Listen to cart changes and update computed values
    ever(_cartItems, _updateComputedValues);

    // Listen to app lifecycle changes
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.paused.toString() ||
          msg == AppLifecycleState.detached.toString()) {
        // Save cart when app goes to background or is closed
        if (_isStorageInitialized) {
          _saveCartToStorage();
          Get.log('Cart saved due to app lifecycle change: $msg');
        }
      }
      return null;
    });

    // Initialize storage and load cart asynchronously
    _initializeStorageAndLoadCart();
  }

  Future<void> _initializeStorageAndLoadCart() async {
    try {
      Get.log('Initializing SharedPreferences in CartController...');
      final prefs = await SharedPreferences.getInstance();
      _storage = prefs;
      _isStorageInitialized = true;
      Get.log('SharedPreferences initialized successfully in CartController');

      // Load cart from storage after successful initialization
      _loadCartFromStorage();
    } catch (e) {
      Get.log(
        'Failed to initialize SharedPreferences in CartController: $e',
        isError: true,
      );
      // Keep using mock storage
      _storage = MockStorage();
      _isStorageInitialized = false;

      // Still try to load cart (will use mock storage)
      _loadCartFromStorage();
    }
  }

  void _updateComputedValues(List<CartItem> items) {
    _itemCount.value = items.fold(0, (sum, item) => sum + item.quantity);
    _totalPrice.value = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    _isEmpty.value = items.isEmpty;

    // Save to local storage whenever cart changes (only if storage is initialized)
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Load cart from local storage
  void _loadCartFromStorage() {
    try {
      if (_storage is MockStorage) {
        Get.log('Using MockStorage - cart will not persist');
        return;
      }

      final String? storedData = _storage.getString(_storageKey);
      if (storedData != null && storedData.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(storedData);
        final List<CartItem> loadedItems =
            jsonData.map((item) => CartItem.fromJson(item)).toList();

        // Update cart items
        _cartItems.value = loadedItems;

        // Update computed values manually since we're bypassing the listener
        _itemCount.value = loadedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        _totalPrice.value = loadedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        _isEmpty.value = loadedItems.isEmpty;

        Get.log(
          'Cart loaded from storage: ${loadedItems.length} items, total: ₹${_totalPrice.value.toStringAsFixed(2)}',
        );
      } else {
        Get.log('No cart data found in storage, starting with empty cart');
        _cartItems.value = [];
      }
    } catch (e) {
      Get.log('Error loading cart from storage: $e', isError: true);
      // If there's an error loading, start with empty cart
      _cartItems.value = [];
    }
  }

  // Save cart to local storage
  void _saveCartToStorage() {
    try {
      if (_storage is MockStorage) {
        Get.log('Cannot save cart - using MockStorage');
        return;
      }

      if (!_isStorageInitialized) {
        Get.log('Storage not yet initialized, skipping save');
        return;
      }

      final List<Map<String, dynamic>> cartData =
          _cartItems.map((item) => item.toJson()).toList();
      final String jsonString = json.encode(cartData);
      _storage.setString(_storageKey, jsonString);

      Get.log(
        'Cart saved to storage: ${_cartItems.length} items, total: ₹${_totalPrice.value.toStringAsFixed(2)}',
      );
    } catch (e) {
      Get.log('Error saving cart to storage: $e', isError: true);
    }
  }

  // Clear local storage
  void _clearStorage() {
    try {
      if (_storage is MockStorage) return;

      _storage.remove(_storageKey);
      Get.log('Cart storage cleared');
    } catch (e) {
      Get.log('Error clearing cart storage: $e', isError: true);
    }
  }

  // Force save cart to storage (useful for debugging)
  void forceSaveCart() {
    if (_isStorageInitialized) {
      _saveCartToStorage();
      Get.log('Cart force saved to storage');
    } else {
      Get.log('Cannot force save - storage not initialized');
    }
  }

  // Force load cart from storage (useful for debugging)
  void forceLoadCart() {
    if (_isStorageInitialized) {
      _loadCartFromStorage();
      Get.log('Cart force loaded from storage');
    } else {
      Get.log('Cannot force load - storage not initialized');
    }
  }

  // Refresh cart from storage (useful for testing persistence)
  void refreshCartFromStorage() {
    if (_isStorageInitialized) {
      final currentItemCount = _cartItems.length;
      final currentTotal = _totalPrice.value;

      _loadCartFromStorage();

      final newItemCount = _cartItems.length;
      final newTotal = _totalPrice.value;

      Get.log(
        'Cart refreshed from storage: $currentItemCount → $newItemCount items, ₹${currentTotal.toStringAsFixed(2)} → ₹${newTotal.toStringAsFixed(2)}',
      );
    } else {
      Get.log('Cannot refresh cart - storage not initialized');
    }
  }

  // Add product to cart with validation
  void addToCart(Product product) {
    if (!product.inStock) {
      Get.snackbar(
        'Out of Stock',
        'This product is currently unavailable',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Increase quantity if product already exists
      _cartItems[existingIndex].quantity++;
      _cartItems.refresh();
    } else {
      // Add new product to cart
      _cartItems.add(CartItem(product: product));

      // Show success feedback
      Get.snackbar(
        'Added to Cart',
        '${product.name} added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }

    // Ensure cart is saved immediately
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Remove product from cart
  void removeFromCart(int productId) {
    final removedItem = _cartItems.firstWhereOrNull(
      (item) => item.product.id == productId,
    );
    if (removedItem != null) {
      _cartItems.removeWhere((item) => item.product.id == productId);

      // Show feedback
      Get.snackbar(
        'Removed from Cart',
        '${removedItem.product.name} removed from your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }

    // Ensure cart is saved immediately
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Decrease quantity with validation
  void decreaseQuantity(int productId) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex].quantity--;
        _cartItems.refresh();
      } else {
        removeFromCart(productId);
      }
    }

    // Ensure cart is saved immediately
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Increase quantity with validation
  void increaseQuantity(int productId) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      // Check if product is still in stock
      if (_cartItems[existingIndex].quantity < 99) {
        // Reasonable limit
        _cartItems[existingIndex].quantity++;
        _cartItems.refresh();
      } else {
        Get.snackbar(
          'Quantity Limit',
          'Maximum quantity limit reached',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }

    // Ensure cart is saved immediately
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Clear entire cart
  void clearCart() {
    if (_cartItems.isNotEmpty) {
      _cartItems.clear();

      Get.snackbar(
        'Cart Cleared',
        'All items removed from your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.secondaryContainer,
        colorText: Get.theme.colorScheme.onSecondaryContainer,
      );

      // Ensure cart is saved immediately
      if (_isStorageInitialized) {
        _saveCartToStorage();
      }
    }
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  // Get quantity of specific product
  int getQuantity(int productId) {
    final item = _cartItems.firstWhereOrNull(
      (item) => item.product.id == productId,
    );
    return item?.quantity ?? 0;
  }

  // Get cart item by product ID
  CartItem? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Update quantity directly
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    if (newQuantity > 99) {
      Get.snackbar(
        'Quantity Limit',
        'Maximum quantity limit is 99',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity = newQuantity;
      _cartItems.refresh();
    }

    // Ensure cart is saved immediately
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Get cart summary for analytics
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalPrice': totalPrice,
      'uniqueProducts': _cartItems.length,
      'isEmpty': isEmpty,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // Checkout validation
  bool get canCheckout => !isEmpty && totalPrice > 0;

  // Export cart data (for backup/sharing)
  Map<String, dynamic> exportCart() {
    return {
      'cartItems': _cartItems.map((item) => item.toJson()).toList(),
      'summary': getCartSummary(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Import cart data (for restore)
  void importCart(Map<String, dynamic> cartData) {
    try {
      final List<dynamic> itemsData = cartData['cartItems'] ?? [];
      final List<CartItem> importedItems =
          itemsData.map((item) => CartItem.fromJson(item)).toList();

      _cartItems.value = importedItems;

      Get.snackbar(
        'Cart Restored',
        'Cart data imported successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      Get.snackbar(
        'Import Failed',
        'Failed to import cart data',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      Get.log('Error importing cart: $e', isError: true);
    }
  }

  // Reset cart to default state
  void resetCart() {
    _cartItems.clear();
    _clearStorage();

    Get.snackbar(
      'Cart Reset',
      'Cart has been reset to default state',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.secondaryContainer,
      colorText: Get.theme.colorScheme.onSecondaryContainer,
    );

    // Ensure cart is saved immediately (even though it's empty)
    if (_isStorageInitialized) {
      _saveCartToStorage();
    }
  }

  // Test cart persistence (useful for debugging)
  void testCartPersistence() {
    if (!_isStorageInitialized) {
      Get.log('Cannot test persistence - storage not initialized');
      return;
    }

    // Add a test product if cart is empty
    if (_cartItems.isEmpty) {
      final testProduct = Product(
        id: 999,
        name: 'Test Product',
        description: 'This is a test product for persistence testing',
        price: 9.99,
        image: 'https://via.placeholder.com/150',
        category: 'Test',
        rating: 5.0,
        reviews: 1,
        inStock: true,
      );

      addToCart(testProduct);
      Get.log('Test product added to cart for persistence testing');
    } else {
      // Clear cart and verify it's saved
      final itemCount = _cartItems.length;
      clearCart();
      Get.log('Cart cleared for persistence testing (was $itemCount items)');
    }
  }

  // Get storage information for debugging
  Map<String, dynamic> getStorageInfo() {
    return {
      'isInitialized': _isStorageInitialized,
      'storageType': _storage.runtimeType.toString(),
      'cartItemCount': _cartItems.length,
      'totalItems': itemCount,
      'totalPrice': totalPrice,
      'isEmpty': isEmpty,
    };
  }

  @override
  void onClose() {
    // Save cart before closing
    _saveCartToStorage();
    super.onClose();
  }
}
