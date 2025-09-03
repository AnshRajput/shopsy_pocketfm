import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    // Default to system theme
    _isDarkMode.value =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        _isDarkMode.value = false;
        break;
      case ThemeMode.dark:
        _isDarkMode.value = true;
        break;
      case ThemeMode.system:
        _isDarkMode.value =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        break;
    }
    Get.changeThemeMode(mode);
  }
}
