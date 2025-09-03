import 'package:get/get.dart';
import '../modules/home/home_view.dart';
import '../modules/product_detail/product_detail_view.dart';
import '../modules/cart/cart_view.dart';
import '../bindings/initial_bindings.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: InitialBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: InitialBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: false, // Allow viewing same product multiple times
    ),
    GetPage(
      name: Routes.cart,
      page: () => const CartView(),
      binding: InitialBindings(),
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: true,
    ),
  ];
}
