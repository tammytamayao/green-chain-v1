class Demand {
  final int id;
  final double weight;
  final String status;
  final int stallId;
  final int productId;
  final String productName;
  final String productVariant;
  final String stallName;
  final String stallLocation;
  final double? currentPrice;
  final int requestsCount;

  Demand({
    required this.id,
    required this.weight,
    required this.status,
    required this.stallId,
    required this.productId,
    required this.productName,
    required this.productVariant,
    required this.stallName,
    required this.stallLocation,
    this.currentPrice,
    required this.requestsCount,
  });

  String get displayName {
    final variant = productVariant.trim();
    final name = productName.trim();
    return variant.isEmpty ? name : '$variant $name';
  }

  bool get isOpen => status == 'open';
  bool get isCompleted => status == 'completed';

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
      status: (json['status'] as String?) ?? 'open',
      stallId: json['stall_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
      stallName: json['stall_name'] as String,
      stallLocation: json['stall_location'] as String,
      currentPrice: json['current_price'] == null
          ? null
          : (json['current_price'] as num).toDouble(),
      requestsCount: (json['requests_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'status': status,
    'stall_id': stallId,
    'product_id': productId,
    'product_name': productName,
    'product_variant': productVariant,
    'stall_name': stallName,
    'stall_location': stallLocation,
    'current_price': currentPrice,
    'requests_count': requestsCount,
  };
}
