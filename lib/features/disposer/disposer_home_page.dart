import 'package:flutter/material.dart';
import '../../../../../auth_api.dart';
import '../../../../../account_page.dart';

import '../../../../../ui/green_theme.dart';
import '../../../../../widgets/banner_header.dart';
import '../../../../../widgets/bottom_nav.dart';
import 'disposer_orders_page.dart';

class DisposerHomePage extends StatefulWidget {
  const DisposerHomePage({super.key});

  @override
  State<DisposerHomePage> createState() => _DisposerHomePageState();
}

class _DisposerHomePageState extends State<DisposerHomePage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  final List<Map<String, dynamic>> _inventory = const [
    {
      'name': 'Green Ice Lettuce',
      'price': 50.00,
      'unit': '/kg',
      'asset': 'assets/green_ice.jpg',
      'stock': 120,
      'orders': 35,
    },
    {
      'name': 'Iceberg Lettuce',
      'price': 40.00,
      'unit': '/kg',
      'asset': 'assets/iceberg.jpg',
      'stock': 75,
      'orders': 18,
    },
    {
      'name': 'Romaine Lettuce',
      'price': 30.00,
      'unit': '/kg',
      'asset': 'assets/romaine.jpg',
      'stock': 52,
      'orders': 22,
    },
  ];

  static const primaryGreen = GreenTheme.primary;
  static const chipGreen = Color(0xFF4F7652);
  static const softBg = GreenTheme.softBg;

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

  String _niceNow() {
    final now = DateTime.now();
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final h = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final mm = now.minute.toString().padLeft(2, '0');
    return '${m[now.month - 1]} ${now.day}, ${now.year} | $h:$mm $ampm';
  }

  void _goHome() {
    // already here
  }

  void _goMiddle() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DisposerOrdersPage()),
    );
  }

  void _goAccount() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );

  @override
  Widget build(BuildContext context) {
    final loading = _profile == null;

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

                // Section title — INVENTORY
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventory',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _niceNow(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Inventory list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList.separated(
                    itemCount: _inventory.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final it = _inventory[i];
                      return _InventoryCard(
                        name: it['name'] as String,
                        price: (it['price'] as num).toDouble(),
                        unit: it['unit'] as String,
                        assetPath: it['asset'] as String,
                        stock: it['stock'] as int,
                        orders: it['orders'] as int,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.disposer, // <-- disposer role
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goMiddle,
        onAccount: _goAccount,
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.name,
    required this.price,
    required this.unit,
    required this.assetPath,
    required this.stock,
    required this.orders,
  });

  final String name;
  final double price;
  final String unit;
  final String assetPath;
  final int stock;
  final int orders;

  static const chipGreen = _DisposerHomePageState.chipGreen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Text(
                  '₱${price.toStringAsFixed(2)} $unit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: chipGreen,
                  ),
                ),
                const SizedBox(height: 14),

                // Stock + Orders
                Row(
                  children: [
                    _StatPill(label: 'Stock', value: '$stock'),
                    const SizedBox(width: 12),
                    _StatPill(label: 'Orders', value: '$orders'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // RIGHT: large image
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/romaine.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _DisposerHomePageState.chipGreen.withAlpha((0.15 * 255).round()),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14, // bigger
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
