import 'package:flutter/material.dart';
import 'api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Flask',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(title: 'Todos (Flask backend)'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Todo>> _future;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = Api.fetchTodos();
  }

  void _reload() => setState(() => _future = Api.fetchTodos());

  Future<void> _add() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    await Api.addTodo(t);
    _ctrl.clear();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Add a todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _add, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Todo>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final todos = snap.data ?? const <Todo>[];
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos yet'));
                }
                return ListView.separated(
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = todos[i];
                    return ListTile(
                      title: Text(
                        t.title,
                        style: TextStyle(
                          decoration: t.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Icon(
                        t.done ? Icons.check_circle : Icons.circle_outlined,
                      ),
                      onTap: () async {
                        await Api.toggle(t.id);
                        _reload();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
