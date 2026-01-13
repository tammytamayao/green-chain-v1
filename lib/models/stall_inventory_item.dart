class StallInventoryItem {
  final int id;
  final int productId;
  final int stallId;
  final String stallName; // <--- NEW
  final String productName;
  final String productVariant;
  final double? currentPrice;
  final double? variantPrice;
  final double stocks;
  final String size;
  final String type;
  final String freshness;
  final String itemClass;
  final int ordersCount;

  StallInventoryItem({
    required this.id,
    required this.productId,
    required this.stallId,
    required this.stallName, // <--- NEW
    required this.productName,
    required this.productVariant,
    required this.currentPrice,
    required this.variantPrice,
    required this.stocks,
    required this.size,
    required this.type,
    required this.freshness,
    required this.itemClass,
    required this.ordersCount,
  });

  String get displayName => '$productVariant $productName';

  factory StallInventoryItem.fromJson(Map<String, dynamic> json) {
    return StallInventoryItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      stallId: json['stall_id'] as int,
      stallName: json['stall_name'] as String, // <--- NEW
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
      currentPrice: json['current_price'] == null
          ? null
          : (json['current_price'] as num).toDouble(),
      variantPrice: json['variant_price'] == null
          ? null
          : (json['variant_price'] as num).toDouble(),
      stocks: (json['stocks'] as num).toDouble(),
      size: json['size'] as String,
      type: json['type'] as String,
      freshness: json['freshness'] as String,
      itemClass: json['class'] as String,
      ordersCount: json['orders_count'] is int
          ? json['orders_count'] as int
          : (json['orders_count'] as num).toInt(),
    );
  }
}
