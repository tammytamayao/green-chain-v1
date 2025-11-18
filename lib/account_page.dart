import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'home_farmer.dart';
import 'stalls_page.dart';
import 'login_page.dart';
import 'driver_home.dart';
import 'driver_drive_page.dart';

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
  Map<String, dynamic>? _profile; // null = loading
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                // Profile summary card
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

                // Role-specific cards
                if (type == 'farmer') ...[
                  // Farm details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Farm details',
                        children: [
                          _row(
                            'Farm name',
                            (_profile?['farm_name'] ?? '—') as String,
                          ),
                          _row(
                            'Farm location',
                            (_profile?['farm_location'] ?? '—') as String,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (type == 'disposer') ...[
                  // Business details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Business details',
                        children: [
                          _row(
                            'Entity',
                            (_profile?['entity'] ?? '—') as String,
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
                  // Driver + vehicles
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InfoCard(
                        title: 'Driver details',
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
                ],

                // Logout button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AccountPage.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

      // Dynamic bottom navigation
      bottomNavigationBar: BottomNav(
        role: _roleFrom(type),
        current: AppTab.account,
        onHome: () {
          if (type == 'driver') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DriverHomePage()),
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
                      (_profile?['current_location'] ??
                              'Abatan, Buguias, Benguet')
                          as String,
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
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StallsPage()),
            );
          }
        },
        onAccount: () {}, // already here
      ),
    );
  }

  /* ---------- helper UI ---------- */

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _vehicleRows(dynamic vehiclesJson) {
    if (vehiclesJson is! List) return [const Text('—')];
    if (vehiclesJson.isEmpty) return [const Text('—')];

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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text('Class $klass', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(width: 8),
            Text('• $plate', style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      );
    }).toList();
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

/* ---------- reusable info card ---------- */

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5E8C61).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: AccountPage.primaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
