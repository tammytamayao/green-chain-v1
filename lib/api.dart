import 'dart:convert';
import 'package:http/http.dart' as http;

/// Android emulator reaches the host machine via 10.0.2.2.
/// You can override this at run time with:
/// flutter run --dart-define=API_BASE=http://10.0.2.2:5001
const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:5001',
);

Uri _u(String p) => Uri.parse('$apiBase$p');

class Todo {
  final int id;
  final String title;
  final bool done;

  Todo({required this.id, required this.title, required this.done});

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
    id: j['id'] as int,
    title: j['title'] as String,
    done: j['done'] as bool,
  );

  Map<String, dynamic> toJson() => {"id": id, "title": title, "done": done};
}

class Api {
  static Future<List<Todo>> fetchTodos() async {
    final r = await http.get(_u('/todos'));
    if (r.statusCode != 200) {
      throw Exception('GET /todos failed: ${r.statusCode} ${r.body}');
    }
    final List data = jsonDecode(r.body) as List;
    return data.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Todo> addTodo(String title) async {
    final r = await http.post(
      _u('/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"title": title}),
    );
    if (r.statusCode != 201) {
      throw Exception('POST /todos failed: ${r.statusCode} ${r.body}');
    }
    return Todo.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  static Future<Todo> toggle(int id) async {
    final r = await http.patch(_u('/todos/$id'));
    if (r.statusCode != 200) {
      throw Exception('PATCH /todos/$id failed: ${r.statusCode} ${r.body}');
    }
    return Todo.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
}
