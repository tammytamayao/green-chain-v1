import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'features/disposer/disposer_home_page.dart';
import 'features/disposer/disposer_orders_page.dart';
import 'features/farmer/screens/farmer_home_page.dart';
import 'features/farmer/screens/farmer_stalls_page.dart';
import 'login_page.dart';
import 'features/driver/driver_home.dart';
import 'features/driver/driver_drive_page.dart';

// NEW imports
import 'features/admin/admin_home_page.dart';
import 'features/admin/admin_monitoring_page.dart';
import 'features/consumer/consumer_home_page.dart';
import 'features/consumer/consumer_orders_page.dart';

// Shared UI
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await me().timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _profile = p ?? {};
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = {};
        _error = 'Could not load profile';
      });
    }
  }

  Future<void> _logout() async {
    await clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(onAuthed: () {})),
      (_) => false,
    );
  }

  UserRole _roleFrom(String? t) {
    switch (t) {
      case 'driver':
        return UserRole.driver;
      case 'disposer':
        return UserRole.disposer;
      // admin & consumer reuse farmer-style bottom nav visuals
      default:
        return UserRole.farmer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _profile == null;

    final first = (_profile?['first_name'] ?? '') as String;
    final last = (_profile?['last_name'] ?? '') as String;
    final name = [first, last].where((s) => s.isNotEmpty).join(' ');
    final user = (_profile?['username'] ?? '') as String? ?? '';
    final type = (_profile?['type'] ?? '') as String? ?? '';

    return Scaffold(
      backgroundColor: AccountPage.softBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const BannerHeaderSliver(),

              if (loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AccountPage.primaryGreen,
                    ),
                  ),
                )
              else ...[
                if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Profile summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _InfoCard(
                      title: 'Profile',
                      children: [
                        _row('Full name', name.isEmpty ? '—' : name),
                        _row('Username', user.isEmpty ? '—' : '@$user'),
                        _row('Type', type.isEmpty ? '—' : _titleCase(type)),
                        _row(
                          'Contact',
                          (_profile?['contact_number'] ?? '—') as String,
                        ),
                      ],
                    ),
                  ),
                ),

                if (type == 'farmer') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Farm Details',
                        children: [
                          _row(
                            'Farm name',
                            (_profile?['farm_name'] ?? '—') as String,
                          ),
                          _row(
                            'Location',
                            (_profile?['farm_location'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (type == 'disposer') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Business Details',
                        children: [
                          _row(
                            'Location',
                            (_profile?['location'] ?? '—') as String,
                          ),
                          _row(
                            'Business',
                            (_profile?['business'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (type == 'driver') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Driver Details',
                        children: [
                          _row(
                            'License ID',
                            (_profile?['license_id'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Vehicles',
                        children: _vehicleRows(_profile?['vehicles']),
                      ),
                    ),
                  ),
                ] else if (type == 'admin') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Admin Details',
                        children: [
                          _row('Email', (_profile?['email'] ?? '—') as String),
                          _row(
                            'Organization',
                            (_profile?['organization'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (type == 'consumer') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Consumer Details',
                        children: [
                          _row(
                            'Address',
                            (_profile?['address'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Logout button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 26),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AccountPage.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        role: _roleFrom(type),
        current: AppTab.account,
        onHome: () {
          if (type == 'driver') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DriverHomePage()),
            );
          } else if (type == 'disposer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DisposerHomePage()),
            );
          } else if (type == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          } else if (type == 'consumer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ConsumerHomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FarmerHomePage()),
            );
          }
        },
        onMiddle: () {
          if (type == 'driver') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DriverDrivePage(
                  currentLocation:
                      (_profile?['current_location'] ?? 'Benguet') as String,
                  selectedVehicle:
                      (_profile?['vehicles'] is List &&
                          (_profile!['vehicles'] as List).isNotEmpty)
                      ? Map<String, dynamic>.from(
                          (_profile!['vehicles'] as List).first,
                        )
                      : null,
                ),
              ),
            );
          } else if (type == 'farmer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FarmerStallsPage()),
            );
          } else if (type == 'disposer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DisposerOrdersPage()),
            );
          } else if (type == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminMonitoringPage()),
            );
          } else if (type == 'consumer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ConsumerOrdersPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FarmerHomePage()),
            );
          }
        },
        onAccount: () {},
      ),
    );
  }

  /* ---------- UI Helpers ---------- */

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _vehicleRows(dynamic vehiclesJson) {
    if (vehiclesJson is! List) {
      return [const Text('—', style: TextStyle(fontSize: 16))];
    }
    if (vehiclesJson.isEmpty) {
      return [const Text('—', style: TextStyle(fontSize: 16))];
    }

    return vehiclesJson.map<Widget>((v) {
      final model = (v['model'] ?? '—').toString();
      final klass = (v['class'] ?? '—').toString();
      final plate = (v['plate_number'] ?? '—').toString();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                model,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Class $klass',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 8),
            Text(
              '• $plate',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }).toList();
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5E8C61).withAlpha((0.20 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: AccountPage.primaryGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
