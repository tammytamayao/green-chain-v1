import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_chain_v1/api/auth_api.dart';
import 'package:green_chain_v1/models/demand.dart';

Uri _u(String p) => Uri.parse('$apiBase$p');

Future<List<Demand>> fetchDemands() async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.get(
    _u('/demands'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to load demands: ${r.body}');
  }

  final data = jsonDecode(r.body) as List<dynamic>;
  return data.map((e) => Demand.fromJson(e as Map<String, dynamic>)).toList();
}

/// Upsert-style: creates or updates demand for (stall_id, product_id)
Future<Demand> createOrUpdateDemand({
  required int productId,
  required double weight,
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{'product_id': productId, 'weight': weight};

  final r = await http.post(
    _u('/demands'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to create/update demand: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return Demand.fromJson(data);
}

Future<Demand> updateDemand({required int id, required double weight}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final body = <String, dynamic>{'weight': weight};

  final r = await http.patch(
    _u('/demands/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (r.statusCode != 200) {
    throw Exception('Failed to update demand: ${r.body}');
  }

  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return Demand.fromJson(data);
}

Future<void> deleteDemand(int id) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final r = await http.delete(
    _u('/demands/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (r.statusCode != 204) {
    throw Exception('Failed to delete demand: ${r.body}');
  }
}
