import 'package:flutter/material.dart';
import 'package:green_chain_v1/features/driver/driver_home.dart';
import 'api/auth_api.dart';
import 'features/admin/admin_home_page.dart';
import 'features/consumer/consumer_home_page.dart';
import 'features/disposer/disposer_home_page.dart';
import 'features/farmer/screens/farmer_home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthed});
  final VoidCallback onAuthed;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Widget _homeForType(String type) {
    switch (type) {
      case 'farmer':
        return const FarmerHomePage();
      case 'driver':
        return const DriverHomePage();
      case 'disposer':
        return const DisposerHomePage();
      case 'admin':
        return const AdminHomePage();
      case 'consumer':
        return const ConsumerHomePage();
      default:
        // Neutral / fallback UI if backend sends an unknown role
        return UnknownRolePage(role: type);
    }
  }

  Future<void> _doLogin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await loginUser(_username.text.trim(), _password.text);

      final profile = await me();
      if (profile == null) {
        throw Exception('Could not verify session. Please try again.');
      }

      if (!mounted) return;
      final type = (profile['type'] as String?) ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _homeForType(type)),
      );

      // widget.onAuthed();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 180),
              const SizedBox(height: 40),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _busy
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _doLogin,
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegisterPage(
                        onRegistered: () async {
                          final profile = await me();
                          if (!mounted) return;
                          final type = (profile?['type'] as String?) ?? '';
                          Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => _homeForType(type),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_outlined),
                label: const Text("Create account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Neutral fallback UI for unexpected / unknown roles.
/// This makes more sense than defaulting to Driver UI.
class UnknownRolePage extends StatelessWidget {
  const UnknownRolePage({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final displayRole = role.isEmpty ? 'unknown' : role;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'You are logged in with role: "$displayRole".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please refresh and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await clearToken();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginPage(onAuthed: () {}),
                      ),
                      (_) => false,
                    );
                  }
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
