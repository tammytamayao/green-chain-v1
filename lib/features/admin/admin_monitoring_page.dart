import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/admin/admin_home_page.dart';
import 'package:green_chain_v1/features/admin/admin_api.dart';

class AdminMonitoringPage extends StatefulWidget {
  const AdminMonitoringPage({super.key});

  @override
  State<AdminMonitoringPage> createState() => _AdminMonitoringPageState();
}

class _AdminMonitoringPageState extends State<AdminMonitoringPage> {
  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;

  Map<String, dynamic>? _metrics; // null = loading
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _metrics = null;
      _error = null;
    });
    try {
      final data = await fetchAdminMetrics();
      if (!mounted) return;
      setState(() {
        _metrics = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metrics = {};
        _error = 'Failed to load metrics: $e';
      });
    }
  }

  int _getUserCount(String key) {
    final users = _metrics?['users'] as Map<String, dynamic>? ?? {};
    final val = users[key];
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  int _getIntField(String key) {
    final val = _metrics?[key];
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final loading = _metrics == null;

    return Scaffold(
      backgroundColor: softBg,
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
                    child: CircularProgressIndicator(color: primaryGreen),
                  ),
                )
              else ...[
                if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ),

                // Title + subtitle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Monitoring',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Overview of active users and transactions in the platform.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Users by role
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Users by role',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _UserCountChip(
                                  label: 'Farmers',
                                  count: _getUserCount('farmer'),
                                  icon: Icons.agriculture_outlined,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 8),
                                _UserCountChip(
                                  label: 'Disposers',
                                  count: _getUserCount('disposer'),
                                  icon: Icons.store_mall_directory_outlined,
                                  color: Colors.teal.shade600,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _UserCountChip(
                                  label: 'Drivers',
                                  count: _getUserCount('driver'),
                                  icon: Icons.local_shipping_outlined,
                                  color: Colors.orange.shade600,
                                ),
                                const SizedBox(width: 8),
                                _UserCountChip(
                                  label: 'Consumers',
                                  count: _getUserCount('consumer'),
                                  icon: Icons.person_outline,
                                  color: Colors.blue.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // System stats (requests, stalls, orders, feedbacks)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _StatCard(
                          title: 'Requests',
                          value: _getIntField('requests'),
                          icon: Icons.swap_horiz_outlined,
                          color: Colors.purple.shade600,
                        ),
                        const SizedBox(height: 10),
                        _StatCard(
                          title: 'Stalls',
                          value: _getIntField('stalls'),
                          icon: Icons.storefront_outlined,
                          color: Colors.brown.shade600,
                        ),
                        const SizedBox(height: 10),
                        _StatCard(
                          title: 'Orders',
                          value: _getIntField('orders'),
                          icon: Icons.receipt_long_outlined,
                          color: Colors.indigo.shade600,
                        ),
                        const SizedBox(height: 10),
                        _StatCard(
                          title: 'Feedbacks',
                          value: _getIntField('feedbacks'),
                          icon: Icons.rate_review_outlined,
                          color: Colors.red.shade600,
                        ),
                      ],
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
        role: UserRole.farmer, // reusing visuals
        current: AppTab.middle, // monitoring tab
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomePage()),
          );
        },
        onMiddle: () {
          // already here
        },
        onAccount: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AccountPage()),
          );
        },
      ),
    );
  }
}

class _UserCountChip extends StatelessWidget {
  const _UserCountChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
