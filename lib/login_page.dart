import 'package:flutter/material.dart';
import 'package:green_chain_v1/driver_home.dart';
import 'auth_api.dart';
import 'register_page.dart';
import 'home_farmer.dart'; // <-- for farmer landing

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

  Future<void> _doLogin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await loginUser(_username.text.trim(), _password.text);

      // Verify immediately and branch by role
      final profile = await me();
      if (profile == null) {
        throw Exception('Could not verify session. Please try again.');
      }

      if (!mounted) return;
      final type = (profile['type'] as String?) ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => type == 'farmer'
              ? const FarmerHomePage()
              : const DriverHomePage(), // placeholder for other roles
        ),
      );

      // Optional: also notify MyApp to refresh its FutureBuilder if you keep it
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
                          // After successful registration, branch by role too
                          final profile = await me();
                          if (!mounted) return;
                          final type = (profile?['type'] as String?) ?? '';
                          Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => type == 'farmer'
                                  ? const FarmerHomePage()
                                  : const DriverHomePage(),
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
