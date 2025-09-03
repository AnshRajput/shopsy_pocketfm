import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Theme controller
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);

    // Product controller
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);

    // Cart controller
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
