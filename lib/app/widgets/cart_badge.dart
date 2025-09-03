import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopsy/app/routes/app_pages.dart';
import '../controllers/cart_controller.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? size;
  final Color? badgeColor;
  final Color? textColor;

  const CartBadge({
    super.key,
    this.onPressed,
    this.size,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.shopping_cart, size: size),
          Obx(() {
            final itemCount = CartController.to.itemCount;
            if (itemCount == 0) return const SizedBox.shrink();

            return Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _formatItemCount(itemCount),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
      onPressed: onPressed ?? () => Get.toNamed(Routes.cart),
      tooltip: 'Cart',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }

  String _formatItemCount(int count) {
    if (count <= 0) return '';
    if (count > 999) return '999+';
    if (count > 99) return '99+';
    return count.toString();
  }
}
