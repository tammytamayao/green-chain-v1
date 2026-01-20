// lib/api/supply_api.dart

import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/supply_request.dart';

/// POST /supplies
/// Body:
/// {
///   "product_id": ...,
///   "weight": ...,
///   "demand_id": ...,
///   "price": ...,
///   "method": "gcash" | "cash"
/// }
///
/// Response:
/// {
///   "supply": {...},
///   "request": { id, price, method, status, supply_id, demand_id, farm: {...}, stall: {...} }
/// }
Future<SupplyAndRequestResponse> createSupplyAndRequest({
  required int productId,
  required double weight,
  required int demandId,
  required double price,
  required String method, // "gcash" or "cash"
}) {
  return apiClient.postJson<SupplyAndRequestResponse>(
    '/supplies',
    body: {
      'product_id': productId,
      'weight': weight,
      'demand_id': demandId,
      'price': price,
      'method': method,
    },
    parser: (json) =>
        SupplyAndRequestResponse.fromJson(json as Map<String, dynamic>),
  );
}
