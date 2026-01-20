// lib/api/stall_inventory_api.dart

import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/stall_inventory_item.dart';

/// GET /stall_inventory
Future<List<StallInventoryItem>> fetchStallInventory() async {
  return apiClient.getJson<List<StallInventoryItem>>(
    '/stall_inventory',
    parser: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => StallInventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

/// POST /stall_inventory
Future<StallInventoryItem> createStallInventory({
  required int productId,
  required double stocks,
  required String size,
  required String type,
  required String freshness,
  required String itemClass,
}) async {
  final body = <String, dynamic>{
    'product_id': productId,
    'stocks': stocks,
    'size': size,
    'type': type,
    'freshness': freshness,
    'class': itemClass,
  };

  return apiClient.postJson<StallInventoryItem>(
    '/stall_inventory',
    body: body,
    parser: (json) => StallInventoryItem.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /stall_inventory/:id
Future<StallInventoryItem> updateStallInventory({
  required int id,
  double? stocks,
  String? size,
  String? type,
  String? freshness,
  String? itemClass,
  double? price, // optional
}) async {
  final body = <String, dynamic>{};

  if (stocks != null) body['stocks'] = stocks;
  if (size != null) body['size'] = size;
  if (type != null) body['type'] = type;
  if (freshness != null) body['freshness'] = freshness;
  if (itemClass != null) body['class'] = itemClass;
  if (price != null) body['price'] = price;

  return apiClient.patchJson<StallInventoryItem>(
    '/stall_inventory/$id',
    body: body,
    parser: (json) => StallInventoryItem.fromJson(json as Map<String, dynamic>),
  );
}

/// DELETE /stall_inventory/:id
Future<void> deleteStallInventory(int id) async {
  await apiClient.delete('/stall_inventory/$id', expectedStatus: 204);
}
