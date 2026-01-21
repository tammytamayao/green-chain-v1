// lib/api/orders_api.dart
import 'package:green_chain_v1/api/api_client.dart';

class ConsumerOrder {
  final int id;
  final double amount;
  final String method;
  final int stallInventoryId;
  final int consumerId;
  final String productName;
  final String productVariant;
  final String stallName;
  final String stallLocation;
  final double? orderedKg;

  ConsumerOrder({
    required this.id,
    required this.amount,
    required this.method,
    required this.stallInventoryId,
    required this.consumerId,
    required this.productName,
    required this.productVariant,
    required this.stallName,
    required this.stallLocation,
    required this.orderedKg,
  });

  String get fullProductLabel => '$productVariant $productName';

  factory ConsumerOrder.fromJson(Map<String, dynamic> json) {
    return ConsumerOrder(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      stallInventoryId: json['stall_inventory_id'] as int,
      consumerId: json['consumer_id'] as int,
      productName: json['product_name'] as String,
      productVariant: json['product_variant'] as String,
      stallName: json['stall_name'] as String,
      stallLocation: json['stall_location'] as String? ?? '',
      orderedKg: json['ordered_kg'] == null
          ? null
          : (json['ordered_kg'] as num).toDouble(),
    );
  }
}

/// GET /orders
Future<List<ConsumerOrder>> fetchOrders() {
  return apiClient.getJson<List<ConsumerOrder>>(
    '/orders',
    parser: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => ConsumerOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

/// POST /orders
Future<ConsumerOrder> createOrder({
  required int stallInventoryId,
  required double amount,
  required String method, // "gcash" | "cash"
}) {
  return apiClient.postJson<ConsumerOrder>(
    '/orders',
    body: {
      'stall_inventory_id': stallInventoryId,
      'amount': amount,
      'method': method,
    },
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}
