// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String variant;
  double? currentPrice;

  Product({
    required this.id,
    required this.name,
    required this.variant,
    this.currentPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      variant: json['variant'] as String,
      currentPrice: json['current_price'] == null
          ? null
          : (json['current_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variant': variant,
      'current_price': currentPrice,
    };
  }
}
