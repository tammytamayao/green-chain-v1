import 'package:flutter/material.dart';
import '../../api/auth_api.dart';
import '../../../../../account_page.dart';

import '../../../../../ui/green_theme.dart';
import '../../../../../widgets/banner_header.dart';
import '../../../../../widgets/bottom_nav.dart';
import 'disposer_orders_page.dart';

import 'package:green_chain_v1/models/product.dart';
import 'package:green_chain_v1/api/product_api.dart' show fetchProducts;
import 'package:green_chain_v1/models/stall_inventory_item.dart';
import 'package:green_chain_v1/api/stall_inventory_api.dart'
    show fetchStallInventory;

class DisposerHomePage extends StatefulWidget {
  const DisposerHomePage({super.key});

  @override
  State<DisposerHomePage> createState() => _DisposerHomePageState();
}

class _DisposerHomePageState extends State<DisposerHomePage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  // Stall inventory rows from backend (for this disposer’s stall)
  List<StallInventoryItem> _inventory = [];
  bool _loadingInventory = true;
  String? _inventoryError;

  // Products from backend
  List<Product> _products = [];
  bool _loadingProducts = true;
  String? _productsError;

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
      final inventory = await fetchStallInventory();
      final products = await fetchProducts();

      if (!mounted) return;
      setState(() {
        _profile = p ?? {};
        _error = null;

        _inventory = inventory;
        _loadingInventory = false;
        _inventoryError = null;

        _products = products;
        _loadingProducts = false;
        _productsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile ??= {};
        _error ??= 'Could not load profile';

        _inventory = [];
        _loadingInventory = false;
        _inventoryError ??= 'Could not load inventory';

        _products = [];
        _loadingProducts = false;
        _productsError ??= 'Could not load products';
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

  // Image path derived from product variant:
  // "Green Ice" -> assets/green_ice.jpg
  String _assetForProductVariant(String variant) {
    final slug = variant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return 'assets/$slug.jpg';
  }

  /// Aggregate total stocks and orders across all stall_inventory rows
  /// for this product (for this disposer’s stall).
  (double totalStocks, int totalOrders) _statsForProduct(Product product) {
    final matching = _inventory.where((it) => it.productId == product.id);
    double stocks = 0.0;
    int orders = 0;
    for (final it in matching) {
      stocks += it.stocks;
      orders += it.ordersCount;
    }
    return (stocks, orders);
  }

  @override
  Widget build(BuildContext context) {
    final loadingProfile = _profile == null;
    final loading = loadingProfile || _loadingInventory || _loadingProducts;
    final hasProducts = _products.isNotEmpty;

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
                if (_productsError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        _productsError!,
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

                // Product-based list (like Farmer), with stats from stall_inventory
                if (!hasProducts)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask the admin to add products.\n'
                            'Stocks and orders will show automatically here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    sliver: SliverList.separated(
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final p = _products[i];
                        final (totalStocks, totalOrders) = _statsForProduct(p);

                        final name = '${p.variant} ${p.name}';
                        final price = p.currentPrice ?? 0.0;
                        final asset = _assetForProductVariant(p.variant);

                        return _InventoryCard(
                          name: name,
                          price: price,
                          unit: '/kg',
                          assetPath: asset,
                          stock: totalStocks,
                          orders: totalOrders,
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
        role: UserRole.disposer, // disposer role
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goMiddle,
        onAccount: _goAccount,
      ),
    );
  }
}

// === UI components: retained Disposer UI, only data changed ===

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
  final double stock; // aggregated, but shown as whole kg
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
          // LEFT: text & stats
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
                    _StatPill(
                      label: 'Stock',
                      value: stock.toStringAsFixed(0), // as whole kg
                    ),
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
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
