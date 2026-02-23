// lib/api/order_api.dart
import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/order.dart';
import 'package:green_chain_v1/models/order_create_response.dart';

/// GET /orders
Future<List<ConsumerOrder>> fetchOrders() {
  return apiClient.getJson<List<ConsumerOrder>>(
    '/orders',
    parser: (json) {
      final list = (json as List<dynamic>? ?? const []);
      return list
          .map((e) => ConsumerOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

/// POST /orders
Future<OrderCreateResponse> createOrder({
  required int stallInventoryId,
  required double amount,
  required String method, // "gcash" | "cash"
  required double weightKg,
}) {
  return apiClient.postJson<OrderCreateResponse>(
    '/orders',
    body: {
      'stall_inventory_id': stallInventoryId,
      'amount': amount,
      'method': method,
      'weight': weightKg,
    },
    parser: (json) =>
        OrderCreateResponse.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /orders/<id>/status  (disposer-only)
Future<ConsumerOrder> updateOrderStatus({
  required int orderId,
  required String status,
}) {
  return apiClient.patchJson<ConsumerOrder>(
    '/orders/$orderId/status',
    body: {'status': status},
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /orders/<id>/receive (consumer-only)
Future<ConsumerOrder> receiveOrder({required int orderId}) {
  return apiClient.patchJson<ConsumerOrder>(
    '/orders/$orderId/receive',
    body: const {},
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}
