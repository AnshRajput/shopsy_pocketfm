import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../data/models/product.dart';
import '../data/models/cart_item.dart';

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

  // Checkout validation
  bool get canCheckout => !isEmpty && totalPrice > 0;

  @override
  void onClose() {
    // Save cart before closing
    _saveCartToStorage();
    super.onClose();
  }
}

// Mock storage for when SharedPreferences is not available
class MockStorage {
  dynamic read(String key) => null;
  void write(String key, dynamic value) {}
  void remove(String key) {}
}
