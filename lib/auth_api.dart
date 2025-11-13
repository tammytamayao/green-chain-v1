import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:5001',
);

final _storage = const FlutterSecureStorage();
const _tokenKey = 'auth_token';

Uri _u(String p) => Uri.parse('$apiBase$p');

Future<void> saveToken(String token) =>
    _storage.write(key: _tokenKey, value: token);
Future<String?> getToken() => _storage.read(key: _tokenKey);
Future<void> clearToken() => _storage.delete(key: _tokenKey);

/// Register user with general fields + type-specific fields.
/// `vehicles` is only used for drivers. Each vehicle is a map:
///   {"model": "...", "class": "...", "plate_number": "..."}
Future<void> registerUser({
  required String firstName,
  required String lastName,
  required String contactNumber,
  required String username,
  required String password,
  required String type, // "farmer" | "disposer" | "driver"
  // farmer
  String? farmName,
  String? farmLocation,

  // disposer
  String? entity,
  String? business,

  // driver
  String? licenseId,
  List<Map<String, String>> vehicles = const [],
}) async {
  final payload = <String, dynamic>{
    'first_name': firstName,
    'last_name': lastName,
    'contact_number': contactNumber,
    'username': username,
    'password': password,
    'type': type,
  };

  if (type == 'farmer') {
    payload['farm_name'] = farmName;
    payload['farm_location'] = farmLocation;
  } else if (type == 'disposer') {
    payload['entity'] = entity;
    payload['business'] = business;
  } else if (type == 'driver') {
    payload['license_id'] = licenseId;
    payload['vehicles'] = vehicles;
  }

  final r = await http.post(
    _u('/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );
  if (r.statusCode != 201) {
    throw Exception('Register failed: ${r.body}');
  }
  final token = (jsonDecode(r.body) as Map<String, dynamic>)['token'] as String;
  await saveToken(token);
}

Future<void> loginUser(String username, String password) async {
  final r = await http.post(
    _u('/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );
  if (r.statusCode != 200) {
    throw Exception('Login failed: ${r.body}');
  }
  final token = (jsonDecode(r.body) as Map<String, dynamic>)['token'] as String;
  await saveToken(token);
}

Future<Map<String, dynamic>?> me() async {
  final token = await getToken();
  if (token == null) return null;
  final r = await http.get(
    _u('/me'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (r.statusCode != 200) return null;
  return jsonDecode(r.body) as Map<String, dynamic>;
}

// (unchanged) authorized helpers
Future<List<Map<String, dynamic>>> fetchTodos() async {
  final token = await getToken();
  final r = await http.get(
    _u('/todos'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (r.statusCode != 200) throw Exception('GET /todos failed: ${r.body}');
  return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
}

Future<void> addTodo(String title) async {
  final token = await getToken();
  final r = await http.post(
    _u('/todos'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'title': title}),
  );
  if (r.statusCode != 201) throw Exception('POST /todos failed: ${r.body}');
}

Future<void> toggleTodo(int id) async {
  final token = await getToken();
  final r = await http.patch(
    _u('/todos/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (r.statusCode != 200)
    throw Exception('PATCH /todos/$id failed: ${r.body}');
}
