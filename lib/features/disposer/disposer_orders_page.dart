import 'package:flutter/material.dart';
import '../../../auth_api.dart';
import '../../../account_page.dart';

import '../../../ui/green_theme.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/bottom_nav.dart';
import 'disposer_home_page.dart';
import 'disposer_orders_model.dart';
import 'widget/buy_tab_sliver.dart';
import 'widget/orders_header_sliver.dart';
import 'widget/orders_segment_switch_sliver.dart';
import 'widget/sell_tab_sliver.dart';

class DisposerOrdersPage extends StatefulWidget {
  const DisposerOrdersPage({super.key});

  @override
  State<DisposerOrdersPage> createState() => _DisposerOrdersPageState();
}

class _DisposerOrdersPageState extends State<DisposerOrdersPage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  int _tabIndex = 0; // 0 = Buy, 1 = Sell

  // Mock data — you can later wire to backend
  final List<MarketItem> _marketItems = const [
    MarketItem(
      name: 'Green Ice Lettuce',
      price: 48.00,
      unit: '/kg',
      assetPath: 'assets/green_ice.jpg',
      available: 200,
    ),
    MarketItem(
      name: 'Iceberg Lettuce',
      price: 38.00,
      unit: '/kg',
      assetPath: 'assets/iceberg.jpg',
      available: 160,
    ),
    MarketItem(
      name: 'Romaine Lettuce',
      price: 32.00,
      unit: '/kg',
      assetPath: 'assets/romaine.jpg',
      available: 120,
    ),
  ];

  final List<SellLot> _sellLots = const [
    SellLot(
      name: 'Green Ice Lettuce',
      price: 52.00,
      unit: '/kg',
      assetPath: 'assets/green_ice.jpg',
      quantity: 80,
      status: 'Open',
    ),
    SellLot(
      name: 'Iceberg Lettuce',
      price: 42.00,
      unit: '/kg',
      assetPath: 'assets/iceberg.jpg',
      quantity: 50,
      status: 'Partially filled',
    ),
    SellLot(
      name: 'Romaine Lettuce',
      price: 35.00,
      unit: '/kg',
      assetPath: 'assets/romaine.jpg',
      quantity: 40,
      status: 'Completed',
    ),
  ];

  // Saved buy requests per item (by name)
  final Map<String, double> _buyRequests = {};

  static const primaryGreen = GreenTheme.primary;
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

  void _goHome() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const DisposerHomePage()),
  );

  void _goMiddle() {
    // already here
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

                OrdersHeaderSliver(dateText: _niceNow()),

                OrdersSegmentSwitchSliver(
                  tabIndex: _tabIndex,
                  onTabChanged: (idx) => setState(() => _tabIndex = idx),
                ),

                if (_tabIndex == 0)
                  BuyTabSliver(
                    items: _marketItems,
                    buyRequests: _buyRequests,
                    onSaveRequest: (name, value) {
                      setState(() {
                        _buyRequests[name] = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saved request: ${value.toStringAsFixed(2)} kg of $name',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  )
                else
                  SellTabSliver(items: _sellLots),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.disposer,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goMiddle,
        onAccount: _goAccount,
      ),
    );
  }
}
