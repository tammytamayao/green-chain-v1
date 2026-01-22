import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/order.dart';

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
  required double weightKg, // ✅ backend expects "weight"
}) {
  return apiClient.postJson<ConsumerOrder>(
    '/orders',
    body: {
      'stall_inventory_id': stallInventoryId,
      'amount': amount,
      'method': method,
      'weight': weightKg, // ✅
    },
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /orders/<id>/status  ✅ Disposer action
Future<ConsumerOrder> updateOrderStatus({
  required int orderId,
  required String status, // accepted/rejected/completed/cancelled/processing
}) {
  return apiClient.patchJson<ConsumerOrder>(
    '/orders/$orderId/status',
    body: {'status': status},
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}

Future<ConsumerOrder> receiveOrder({required int orderId}) {
  return apiClient.patchJson<ConsumerOrder>(
    '/orders/$orderId/receive',
    body: {}, // no body needed
    parser: (json) => ConsumerOrder.fromJson(json as Map<String, dynamic>),
  );
}
