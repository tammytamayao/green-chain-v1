import 'dart:convert';
import 'package:green_chain_v1/models/product.dart';
import 'package:http/http.dart' as http;

import 'package:green_chain_v1/auth_api.dart' show apiBase, getToken;

Uri _u(String p) => Uri.parse('$apiBase$p');

Future<List<Product>> fetchProducts() async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.get(
    _u('/products'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to load products: ${r.body}');
  }

  final data = jsonDecode(r.body) as List<dynamic>;
  return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
}

Future<Product> updateProductPrice(int productId, double price) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.patch(
    _u('/products/$productId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'current_price': price}),
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to update price: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return Product.fromJson(data);
}

Future<Product> createProduct({
  required String name,
  required String variant,
  double? currentPrice,
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{'name': name, 'variant': variant};
  if (currentPrice != null) {
    body['current_price'] = currentPrice;
  }

  final r = await http.post(
    _u('/products'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 201) {
    throw Exception('Failed to create product: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return Product.fromJson(data);
}

Future<void> deleteProduct(int productId) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.delete(
    _u('/products/$productId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 204) {
    throw Exception('Failed to delete product: ${r.body}');
  }
}

/// Fetch high-level admin metrics from /system/metrics
/// Shape:
/// {
///   "users": { "farmer": int, "disposer": int, "driver": int, "consumer": int },
///   "requests": int,
///   "stalls": int,
///   "orders": int,
///   "feedbacks": int
/// }
Future<Map<String, dynamic>> fetchAdminMetrics() async {
  final token = await getToken();

  final headers = <String, String>{};
  if (token != null) {
    // In case you later secure /system/metrics, this will already send the token.
    headers['Authorization'] = 'Bearer $token';
  }

  final r = await http.get(_u('/system/metrics'), headers: headers);

  if (r.statusCode != 200) {
    throw Exception('Failed to load metrics: ${r.body}');
  }

  return jsonDecode(r.body) as Map<String, dynamic>;
}
