import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  GetPage? redirect(String? route) {
    // For demo purposes, always allow access
    // In a real app, you would check authentication status here
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Additional navigation logic can be added here
    return await super.redirectDelegate(route);
  }

  @override
  void onPageDispose() {
    // Cleanup when page is disposed
    super.onPageDispose();
  }
}
