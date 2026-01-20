import 'package:flutter/material.dart';

import '../../api/auth_api.dart';
import '../../api/stall_inventory_api.dart';
import '../../models/stall_inventory_item.dart';

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
  Map<String, dynamic>? _profile;
  String? _profileError;

  bool _inventoryLoading = true;
  String? _inventoryError;
  List<_ConsumerProductSummary> _products = const [];

  static const primaryGreen = GreenTheme.primary;
  static const chipGreen = Color(0xFF4F7652);
  static const softBg = GreenTheme.softBg;

  @override
  void initState() {
    super.initState();
    _load(); // load profile + inventory
  }

  /* ==================== DATA LOADING ==================== */

  Future<void> _loadProfile() async {
    try {
      final p = await me().timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _profile = p ?? <String, dynamic>{};
        _profileError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = <String, dynamic>{};
        _profileError = 'Could not load profile';
      });
    }
  }

  Future<void> _loadInventory() async {
    try {
      final items = await fetchStallInventory().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;

      final products = _buildProductSummaries(items);

      setState(() {
        _inventoryLoading = false;
        _inventoryError = null;
        _products = products;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _inventoryLoading = false;
        _inventoryError = 'Could not load available produce';
        _products = const [];
      });
    }
  }

  /// Combined loader for pull-to-refresh.
  Future<void> _load() async {
    await Future.wait([_loadProfile(), _loadInventory()]);
  }

  /// Group stall inventory rows by product display name and compute
  /// min/max price per product.
  List<_ConsumerProductSummary> _buildProductSummaries(
    List<StallInventoryItem> items,
  ) {
    final Map<String, List<StallInventoryItem>> byProduct = {};

    for (final item in items) {
      final key = item.displayName.trim();
      if (key.isEmpty) continue;
      byProduct.putIfAbsent(key, () => <StallInventoryItem>[]).add(item);
    }

    final List<_ConsumerProductSummary> out = [];

    for (final entry in byProduct.entries) {
      final productName = entry.key;
      final productItems = entry.value;

      // Take variantPrice if present, else currentPrice
      final prices = <double>[];
      for (final it in productItems) {
        final p = it.variantPrice ?? it.currentPrice;
        if (p != null) prices.add(p);
      }

      if (prices.isEmpty) {
        // No usable price for this product, skip
        continue;
      }

      double minPrice = prices.first;
      double maxPrice = prices.first;
      for (final p in prices.skip(1)) {
        if (p < minPrice) minPrice = p;
        if (p > maxPrice) maxPrice = p;
      }

      final assetPath = _assetForProductName(productName);

      out.add(
        _ConsumerProductSummary(
          name: productName,
          minPrice: minPrice,
          maxPrice: maxPrice,
          unit: '/kg', // you can adjust later if you support other units
          assetPath: assetPath,
        ),
      );
    }

    // Sort alphabetically by product name
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  /// Map product name to an image asset.
  String _assetForProductName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('green ice')) {
      return 'assets/green_ice.jpg';
    } else if (lower.contains('iceberg')) {
      return 'assets/iceberg.jpg';
    } else if (lower.contains('romaine')) {
      return 'assets/romaine.jpg';
    }
    // fallback
    return 'assets/romaine.jpg';
  }

  /* ==================== UTIL & NAV ==================== */

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

  /* ==================== BUILD ==================== */

  @override
  Widget build(BuildContext context) {
    final bool isProfileLoading = _profile == null;
    final bool loading = isProfileLoading || _inventoryLoading;

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
                if (_profileError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        _profileError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ),

                if (_inventoryError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        _inventoryError!,
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

                if (_products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No produce available right now.\nPlease check again later!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Produce list from stall inventory
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    sliver: SliverList.separated(
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final p = _products[i];
                        return _ConsumerProduceCard(
                          name: p.name,
                          minPrice: p.minPrice,
                          maxPrice: p.maxPrice,
                          unit: p.unit,
                          assetPath: p.assetPath,
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
        // TODO: if you add UserRole.consumer, use that instead of farmer
        role: UserRole.farmer,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goBrowse, // middle = browse stalls/orders
        onAccount: _goAccount,
      ),
    );
  }
}

/* =============== INTERNAL VIEW MODEL =============== */

class _ConsumerProductSummary {
  const _ConsumerProductSummary({
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
}

/* ==================== CARD WIDGET ==================== */

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
