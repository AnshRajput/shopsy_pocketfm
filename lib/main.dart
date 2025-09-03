import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shopsy',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Default to system theme
      defaultTransition: Transition.fadeIn,
    );
  }
}
