import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductSource {
  static const String _productsPath = 'assets/products.json';

  static Future<List<Product>> loadProducts() async {
    try {
      final String response = await rootBundle.loadString(_productsPath);
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
      return [];
    }
  }
}
