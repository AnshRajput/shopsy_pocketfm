import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../data/models/product.dart';
import '../../routes/app_pages.dart';
import '../../widgets/cart_badge.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          CartBadge(onPressed: () => Get.toNamed(Routes.cart)),
          const SizedBox(width: 8), // Right margin
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 64),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            Text(
              product.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Category
            Text(
              product.category,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Rating and Reviews
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${product.rating}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${product.reviews} reviews)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Add to Cart Section
            Obx(() {
              final cartController = CartController.to;
              final isInCart = cartController.isInCart(product.id);

              if (isInCart) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed:
                              () => cartController.decreaseQuantity(product.id),
                          iconSize: 32,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${cartController.getQuantity(product.id)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed:
                              () => cartController.increaseQuantity(product.id),
                          iconSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total: ₹${(product.price * cartController.getQuantity(product.id)).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                );
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => cartController.addToCart(product),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
