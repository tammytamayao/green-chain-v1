// lib/api/stall_inventory_api.dart
import 'dart:convert';
import 'package:green_chain_v1/api/auth_api.dart';
import 'package:http/http.dart' as http;
import 'package:green_chain_v1/models/stall_inventory_item.dart';

Uri _u(String p) => Uri.parse('$apiBase$p');

Future<List<StallInventoryItem>> fetchStallInventory() async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.get(
    _u('/stall_inventory'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to load inventory: ${r.body}');
  }

  final data = jsonDecode(r.body) as List<dynamic>;
  return data
      .map((e) => StallInventoryItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<StallInventoryItem> createStallInventory({
  required int productId,
  required double stocks,
  required String size,
  required String type,
  required String freshness,
  required String itemClass,
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{
    'product_id': productId,
    'stocks': stocks,
    'size': size,
    'type': type,
    'freshness': freshness,
    'class': itemClass,
  };

  final r = await http.post(
    _u('/stall_inventory'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 201) {
    throw Exception('Failed to create inventory: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return StallInventoryItem.fromJson(data);
}

Future<StallInventoryItem> updateStallInventory({
  required int id,
  double? stocks,
  String? size,
  String? type,
  String? freshness,
  String? itemClass,
  double? price, // <--- NEW
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{};
  if (stocks != null) body['stocks'] = stocks;
  if (size != null) body['size'] = size;
  if (type != null) body['type'] = type;
  if (freshness != null) body['freshness'] = freshness;
  if (itemClass != null) body['class'] = itemClass;
  if (price != null) body['price'] = price;

  final r = await http.patch(
    _u('/stall_inventory/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to update inventory: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return StallInventoryItem.fromJson(data);
}

Future<void> deleteStallInventory(int id) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.delete(
    _u('/stall_inventory/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 204) {
    throw Exception('Failed to delete inventory: ${r.body}');
  }
}
