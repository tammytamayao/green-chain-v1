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

  // Not const so we can update variant prices
  final List<SellLot> _sellLots = [
    const SellLot(
      name: 'Green Ice Lettuce',
      unit: '/kg',
      assetPath: 'assets/green_ice.jpg',
      status: 'Open',
      variants: [
        VariantPrice(
          id: 1,
          size: LettuceSize.small,
          variantType: LettuceVariantType.organic,
          price: 55.0,
          stockKg: 20.0,
        ),
        VariantPrice(
          id: 2,
          size: LettuceSize.small,
          variantType: LettuceVariantType.nonOrganic,
          price: 48.0,
          stockKg: 40.0,
        ),
        VariantPrice(
          id: 3,
          size: LettuceSize.big,
          variantType: LettuceVariantType.organic,
          price: 62.0,
          stockKg: 10.0,
        ),
        VariantPrice(
          id: 4,
          size: LettuceSize.big,
          variantType: LettuceVariantType.nonOrganic,
          price: 52.0,
          stockKg: 30.0,
        ),
      ],
    ),
    const SellLot(
      name: 'Iceberg Lettuce',
      unit: '/kg',
      assetPath: 'assets/iceberg.jpg',
      status: 'Partially filled',
      variants: [
        VariantPrice(
          id: 5,
          size: LettuceSize.small,
          variantType: LettuceVariantType.organic,
          price: 45.0,
          stockKg: 15.0,
        ),
        VariantPrice(
          id: 6,
          size: LettuceSize.big,
          variantType: LettuceVariantType.nonOrganic,
          price: 40.0,
          stockKg: 25.0,
        ),
      ],
    ),
    // NEW: Romaine Lettuce sell lot
    const SellLot(
      name: 'Romaine Lettuce',
      unit: '/kg',
      assetPath: 'assets/romaine.jpg',
      status: 'Open',
      variants: [
        VariantPrice(
          id: 7,
          size: LettuceSize.small,
          variantType: LettuceVariantType.organic,
          price: 50.0,
          stockKg: 18.0,
        ),
        VariantPrice(
          id: 8,
          size: LettuceSize.small,
          variantType: LettuceVariantType.nonOrganic,
          price: 42.0,
          stockKg: 22.0,
        ),
        VariantPrice(
          id: 9,
          size: LettuceSize.big,
          variantType: LettuceVariantType.organic,
          price: 58.0,
          stockKg: 12.0,
        ),
        VariantPrice(
          id: 10,
          size: LettuceSize.big,
          variantType: LettuceVariantType.nonOrganic,
          price: 48.0,
          stockKg: 28.0,
        ),
      ],
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
                  SellTabSliver(
                    items: _sellLots,
                    onUpdateVariantPrice: (lot, variant, newPrice) {
                      setState(() {
                        final lotIndex = _sellLots.indexOf(lot);
                        if (lotIndex == -1) return;

                        final currentLot = _sellLots[lotIndex];

                        // Update by (size, variantType) so we can handle missing combos
                        final existingIndex = currentLot.variants.indexWhere(
                          (v) =>
                              v.size == variant.size &&
                              v.variantType == variant.variantType,
                        );

                        List<VariantPrice> updatedVariants =
                            List<VariantPrice>.from(currentLot.variants);

                        if (existingIndex >= 0) {
                          updatedVariants[existingIndex] =
                              updatedVariants[existingIndex].copyWith(
                                price: newPrice,
                              );
                        } else {
                          final newId = currentLot.variants.isEmpty
                              ? 1
                              : currentLot.variants.last.id + 1;

                          updatedVariants.add(
                            VariantPrice(
                              id: newId,
                              size: variant.size,
                              variantType: variant.variantType,
                              price: newPrice,
                              stockKg: 0.0,
                            ),
                          );
                        }

                        _sellLots[lotIndex] = currentLot.copyWith(
                          variants: updatedVariants,
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Updated ${lot.name} '
                            '(${variant.size.label}, ${variant.variantType.label}) '
                            'to ₱${newPrice.toStringAsFixed(2)} ${lot.unit}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.disposer,
        current: AppTab.middle,
        onHome: _goHome,
        onMiddle: _goMiddle,
        onAccount: _goAccount,
      ),
    );
  }
}
