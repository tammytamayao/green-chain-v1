import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'login_page.dart';
import 'todos_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> _authed() async => (await me()) != null;
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Chain',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: FutureBuilder<bool>(
        future: _authed(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snap.data!) {
            return LoginPage(onAuthed: _refresh);
          }
          return const TodosPage();
        },
      ),
    );
  }
}
