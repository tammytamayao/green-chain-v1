import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'login_page.dart';
import 'features/farmer/screens/farmer_home_page.dart';
import 'driver_home.dart'; // <--- add this

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<String, dynamic>?> _profile() async {
    try {
      return await me().timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Chain',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _profile(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final profile = snap.data;
          if (profile == null) {
            return LoginPage(onAuthed: _refresh);
          }
          final type = (profile['type'] as String?) ?? '';
          if (type == 'farmer') {
            return const FarmerHomePage();
          }
          if (type == 'driver') {
            return const DriverHomePage();
          }
          if (type == 'driver') {
            return const DriverHomePage();
          }
          // TODO: route disposer to its own page later
          return const DriverHomePage();
        },
      ),
    );
  }
}
