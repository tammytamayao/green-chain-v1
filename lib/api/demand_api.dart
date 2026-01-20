// lib/api/demand_api.dart

import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/demand.dart';

/// GET /demands
Future<List<Demand>> fetchDemands() {
  return apiClient.getJson<List<Demand>>(
    '/demands',
    parser: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => Demand.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

/// POST /demands  (upsert-style: create or update demand for (stall, product))
Future<Demand> createOrUpdateDemand({
  required int productId,
  required double weight,
}) {
  return apiClient.postJson<Demand>(
    '/demands',
    body: {'product_id': productId, 'weight': weight},
    parser: (json) => Demand.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /demands/:id
Future<Demand> updateDemand({required int id, required double weight}) {
  return apiClient.patchJson<Demand>(
    '/demands/$id',
    body: {'weight': weight},
    parser: (json) => Demand.fromJson(json as Map<String, dynamic>),
  );
}

/// DELETE /demands/:id
Future<void> deleteDemand(int id) {
  return apiClient.delete('/demands/$id', expectedStatus: 204);
}
