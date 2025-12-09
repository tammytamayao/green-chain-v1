import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'login_page.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});
  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final _ctrl = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchTodos();
  }

  void _reload() => setState(() => _future = fetchTodos());

  Future<void> _add() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    try {
      await addTodo(title);
      _ctrl.clear();
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
    }
  }

  Future<void> _logout() async {
    await clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onAuthed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TodosPage()),
            );
          },
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  // Avoid `!` and show the error safely
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final list = snap.data ?? const <Map<String, dynamic>>[];
                if (list.isEmpty) {
                  return const Center(child: Text('No todos yet'));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = list[i];
                    final title = (t['title'] as String?) ?? '(untitled)';
                    final done = (t['done'] as bool?) ?? false;
                    final id = (t['id'] as num?)?.toInt(); // null-safe

                    return ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      leading: Icon(
                        done ? Icons.check_circle : Icons.circle_outlined,
                        color: Colors.green,
                      ),
                      onTap: id == null
                          ? null
                          : () async {
                              try {
                                await toggleTodo(id);
                                _reload();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to toggle: $e'),
                                  ),
                                );
                              }
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
