// lib/models/order.dart

class ConsumerOrder {
  final int id;
  final double amount;
  final String method;
  final int? deliveryId;
  final int stallInventoryId;
  final int consumerId;

  // inventory
  final double stocks;
  final String size;
  final String type;
  final String freshness;
  final String itemClass;
  final double? variantPrice;

  // product
  final int productId;
  final String productName;
  final String productVariant;
  final double? currentPrice;

  // stall
  final int stallId;
  final String stallName;
  final String stallLocation;

  ConsumerOrder({
    required this.id,
    required this.amount,
    required this.method,
    required this.deliveryId,
    required this.stallInventoryId,
    required this.consumerId,
    required this.stocks,
    required this.size,
    required this.type,
    required this.freshness,
    required this.itemClass,
    required this.variantPrice,
    required this.productId,
    required this.productName,
    required this.productVariant,
    required this.currentPrice,
    required this.stallId,
    required this.stallName,
    required this.stallLocation,
  });

  factory ConsumerOrder.fromJson(Map<String, dynamic> json) {
    return ConsumerOrder(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      deliveryId: json['delivery_id'] as int?,
      stallInventoryId: json['stall_inventory_id'] as int,
      consumerId: json['consumer_id'] as int,
      stocks: (json['stocks'] as num).toDouble(),
      size: json['size'] as String,
      type: json['type'] as String,
      freshness: json['freshness'] as String,
      itemClass: json['item_class'] as String,
      variantPrice: json['variant_price'] == null
          ? null
          : (json['variant_price'] as num).toDouble(),
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
      currentPrice: json['current_price'] == null
          ? null
          : (json['current_price'] as num).toDouble(),
      stallId: json['stall_id'] as int,
      stallName: json['stall_name'] as String,
      stallLocation: json['stall_location'] as String,
    );
  }
}
