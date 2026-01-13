// lib/api/supply_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_chain_v1/api/auth_api.dart';

Uri _u(String p) => Uri.parse('$apiBase$p');

Future<Map<String, dynamic>> createSupplyAndRequest({
  required int productId,
  required double weight,
  required int demandId,
  required double price,
  required String method, // "gcash" or "cash"
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{
    'product_id': productId,
    'weight': weight,
    'demand_id': demandId,
    'price': price,
    'method': method,
  };

  final r = await http.post(
    _u('/supplies'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 201) {
    throw Exception('Failed to create supply/request: ${r.body}');
  }

  return jsonDecode(r.body) as Map<String, dynamic>;
}
