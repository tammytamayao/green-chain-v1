import 'package:flutter/material.dart';
import '../../../auth_api.dart';
import '../../../account_page.dart';

import '../../../ui/green_theme.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/bottom_nav.dart';
import 'consumer_orders_page.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePageState();
}

class _ConsumerHomePageState extends State<ConsumerHomePage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  /// For now this is static placeholder data.
  /// Later, you can wire this to your backend prices API and compute min/max.
  final List<Map<String, dynamic>> _items = const [
    {
      'name': 'Green Ice Lettuce',
      'min_price': 45.00,
      'max_price': 55.00,
      'unit': '/kg',
      'asset': 'assets/green_ice.jpg',
    },
    {
      'name': 'Iceberg Lettuce',
      'min_price': 35.00,
      'max_price': 45.00,
      'unit': '/kg',
      'asset': 'assets/iceberg.jpg',
    },
    {
      'name': 'Romaine Lettuce',
      'min_price': 28.00,
      'max_price': 38.00,
      'unit': '/kg',
      'asset': 'assets/romaine.jpg',
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

  // For now reuse FarmerStallsPage as a "Browse stalls" placeholder.
  void _goBrowse() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const ConsumerOrdersPage()),
  );

  void _goAccount() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );

  void _goOrders() {
    // TODO: navigate to a real ConsumerOrdersPage once you have it.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orders screen not implemented yet.')),
    );
  }

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

                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shop Now',
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

                // Produce list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      return _ConsumerProduceCard(
                        name: it['name'] as String,
                        minPrice: (it['min_price'] as num).toDouble(),
                        maxPrice: (it['max_price'] as num).toDouble(),
                        unit: it['unit'] as String,
                        assetPath: it['asset'] as String,
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
        // if you later add UserRole.consumer, swap this
        role: UserRole.farmer,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goBrowse, // middle = browse stalls for now
        onAccount: _goAccount,
      ),
    );
  }
}

class _ConsumerProduceCard extends StatelessWidget {
  const _ConsumerProduceCard({
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    required this.unit,
    required this.assetPath,
  });

  final String name;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final String assetPath;

  static const chipGreen = _ConsumerHomePageState.chipGreen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final priceText =
        '₱${minPrice.toStringAsFixed(2)} - ₱${maxPrice.toStringAsFixed(2)} $unit';

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/romaine.jpg', fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black26],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: chipGreen.withAlpha((0.95 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
