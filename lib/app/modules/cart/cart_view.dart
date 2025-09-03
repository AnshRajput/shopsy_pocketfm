import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../data/models/cart_item.dart';
import 'package:flutter/foundation.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Storage status indicator
          Obx(() {
            final cartController = CartController.to;
            if (cartController.isStorageInitialized) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.storage, size: 16, color: Colors.green[700]),
              );
            } else {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.storage, size: 16, color: Colors.orange[700]),
              );
            }
          }),
          // Cart management menu
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder:
                (BuildContext context) => [
                  // Debug options (only in debug mode)
                  if (kDebugMode) ...[
                    const PopupMenuItem(
                      value: 'force_save',
                      child: Row(
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('Force Save Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'force_load',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Force Load Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'refresh_cart',
                      child: Row(
                        children: [
                          Icon(Icons.sync),
                          SizedBox(width: 8),
                          Text('Refresh Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'storage_status',
                      child: Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Text('Storage Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'test_persistence',
                      child: Row(
                        children: [
                          Icon(Icons.science),
                          SizedBox(width: 8),
                          Text('Test Persistence'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(value: 'divider1', child: Divider()),
                  ],
                  if (controller.cartItems.isNotEmpty) ...[
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Export Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.upload),
                          SizedBox(width: 8),
                          Text('Import Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear Cart'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Reset Cart'),
                        ],
                      ),
                    ),
                  ],
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            // Cart Items List with optimized rendering
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];
                  return CartItemCard(
                    key: ValueKey(cartItem.product.id), // Optimized key
                    cartItem: cartItem,
                  );
                },
              ),
            ),

            // Total and Checkout Section
            _buildCheckoutSection(context),
          ],
        );
      }),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'export':
        _exportCart(context);
        break;
      case 'import':
        _importCart(context);
        break;
      case 'clear':
        _showClearCartDialog(context);
        break;
      case 'reset':
        _showResetCartDialog(context);
        break;
      case 'force_save':
        CartController.to.forceSaveCart();
        Get.snackbar(
          'Cart Saved',
          'Cart data force saved to storage',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        break;
      case 'force_load':
        CartController.to.forceLoadCart();
        Get.snackbar(
          'Cart Loaded',
          'Cart data force loaded from storage',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        break;
      case 'refresh_cart':
        CartController.to.refreshCartFromStorage();
        Get.snackbar(
          'Cart Refreshed',
          'Cart data refreshed from storage',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        break;
      case 'storage_status':
        final storageInfo = CartController.to.getStorageInfo();
        Get.snackbar(
          'Storage Status',
          'Initialized: ${storageInfo['isInitialized']}\nType: ${storageInfo['storageType']}\nItems: ${storageInfo['cartItemCount']}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        break;
      case 'test_persistence':
        CartController.to.testCartPersistence();
        Get.snackbar(
          'Persistence Test',
          'Cart persistence test executed - check logs for details',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.colorScheme.secondaryContainer,
          colorText: Get.theme.colorScheme.onSecondaryContainer,
        );
        break;
    }
  }

  void _exportCart(BuildContext context) {
    final cartData = controller.exportCart();
    final cartJson = cartData.toString();

    // In a real app, you might want to save to file or share
    Get.snackbar(
      'Cart Exported',
      'Cart data exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
    );

    // Log the exported data (for demo purposes)
    Get.log('Exported cart data: $cartJson');
  }

  void _importCart(BuildContext context) {
    // In a real app, you would implement file picker or paste functionality
    Get.snackbar(
      'Import Cart',
      'Import functionality would be implemented here',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.secondaryContainer,
      colorText: Get.theme.colorScheme.onSecondaryContainer,
    );
  }

  void _showResetCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Cart'),
          content: const Text(
            'This will completely reset your cart and clear all stored data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.resetCart();
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cart Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${controller.itemCount}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${controller.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  controller.canCheckout
                      ? () => _showCheckoutDialog(context)
                      : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    controller.canCheckout
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      controller.canCheckout
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to clear all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.clearCart();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total amount: ₹${controller.totalPrice.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              const Text(
                'This is a demo app. Checkout functionality is not implemented.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with optimization
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                cacheWidth: 160,
                cacheHeight: 160,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cartItem.product.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${cartItem.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls with better UX
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          () => CartController.to.decreaseQuantity(
                            cartItem.product.id,
                          ),
                      iconSize: 24,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed:
                          () => CartController.to.increaseQuantity(
                            cartItem.product.id,
                          ),
                      iconSize: 24,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
