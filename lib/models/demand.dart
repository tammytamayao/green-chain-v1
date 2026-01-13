class Demand {
  final int id;
  final double weight;
  final int stallId;
  final String stallName;
  final int productId;
  final String productName;
  final String productVariant;
  final double? currentPrice;
  final int requestsCount;

  Demand({
    required this.id,
    required this.weight,
    required this.stallId,
    required this.stallName,
    required this.productId,
    required this.productName,
    required this.productVariant,
    required this.currentPrice,
    required this.requestsCount,
  });

  String get displayName => '$productVariant $productName';

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
      stallId: json['stall_id'] as int,
      stallName: json['stall_name'] as String,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
      currentPrice: json['current_price'] == null
          ? null
          : (json['current_price'] as num).toDouble(),
      requestsCount: json['requests_count'] == null
          ? 0
          : (json['requests_count'] as num).toInt(),
    );
  }
}
