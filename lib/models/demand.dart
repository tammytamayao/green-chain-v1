class Demand {
  final int id;
  final double weight;
  final int stallId;
  final int productId;
  final String productName;
  final String productVariant;

  Demand({
    required this.id,
    required this.weight,
    required this.stallId,
    required this.productId,
    required this.productName,
    required this.productVariant,
  });

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
      stallId: json['stall_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
    );
  }
}
