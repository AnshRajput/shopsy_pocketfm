class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rating;
  final int reviews;
  final bool inStock;
  final String brand;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.inStock,
    required this.brand,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      inStock: json['inStock'] as bool,
      brand: json['brand'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'inStock': inStock,
      'brand': brand,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? category,
    double? rating,
    int? reviews,
    bool? inStock,
    String? brand,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      inStock: inStock ?? this.inStock,
      brand: brand ?? this.brand,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
