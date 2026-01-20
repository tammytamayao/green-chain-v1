// lib/api/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_chain_v1/api/auth_api.dart';

const String _base = apiBase; // apiBase should be defined in auth_api.dart

Uri _u(String p) => Uri.parse('$_base$p');

class ApiClient {
  const ApiClient();

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<T> getJson<T>(String path, {T Function(dynamic json)? parser}) async {
    final headers = await _authHeaders();
    final res = await http.get(_u(path), headers: headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    return parser != null ? parser(decoded) : decoded as T;
  }

  Future<T> postJson<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) async {
    final headers = {
      ...(await _authHeaders()),
      'Content-Type': 'application/json',
    };

    final res = await http.post(
      _u(path),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    return parser != null ? parser(decoded) : decoded as T;
  }

  Future<T> patchJson<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) async {
    final headers = {
      ...(await _authHeaders()),
      'Content-Type': 'application/json',
    };

    final res = await http.patch(
      _u(path),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PATCH $path failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    return parser != null ? parser(decoded) : decoded as T;
  }

  Future<void> delete(String path, {int expectedStatus = 204}) async {
    final headers = await _authHeaders();
    final res = await http.delete(_u(path), headers: headers);

    if (res.statusCode != expectedStatus) {
      throw Exception('DELETE $path failed: ${res.statusCode} ${res.body}');
    }
  }
}

// simple singleton
const apiClient = ApiClient();
