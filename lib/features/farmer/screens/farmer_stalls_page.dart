import 'package:flutter/material.dart';
import 'package:green_chain_v1/models/product_demand.dart';
import 'package:green_chain_v1/models/stall_demand.dart';

import 'package:green_chain_v1/utils/date_utils.dart';
import 'package:green_chain_v1/api/auth_api.dart';
import 'package:green_chain_v1/api/demand_api.dart';
import 'package:green_chain_v1/models/demand.dart';
import 'package:green_chain_v1/widgets/farmers/demand_section.dart';

import '../../../account_page.dart';
import '../../../ui/green_theme.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/bottom_nav.dart';
import 'farmer_home_page.dart';
import 'farmer_supply_page.dart';

class FarmerStallsPage extends StatefulWidget {
  const FarmerStallsPage({super.key});

  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;
  static const chipBg = Color(0xFF4F7652);

  @override
  State<FarmerStallsPage> createState() => _FarmerStallsPageState();
}

class _FarmerStallsPageState extends State<FarmerStallsPage> {
  Map<String, dynamic>? _profile; // null = loading, {} = loaded but empty
  String? _profileError;

  bool _demandLoading = true;
  String? _demandError;
  List<ProductDemand> _sections = const [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDemands();
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

  Future<void> _loadDemands() async {
    try {
      final items = await fetchDemands().timeout(const Duration(seconds: 8));
      if (!mounted) return;

      // Only keep demands that have NO related requests
      final noRequestItems = items
          .where((d) => d.requestsCount == 0)
          .toList(growable: false);

      final sections = _buildSectionsFromDemands(noRequestItems);

      setState(() {
        _demandLoading = false;
        _demandError = null;
        _sections = sections;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _demandLoading = false;
        _demandError = 'Could not load stall demand';
        _sections = const [];
      });
    }
  }

  /// Group demand rows by product (variant + name) and build UI model sections.
  List<ProductDemand> _buildSectionsFromDemands(List<Demand> items) {
    final Map<String, List<Demand>> byProduct = {};

    for (final item in items) {
      final key = item.displayName.trim(); // e.g. "<variant> <name>"
      byProduct.putIfAbsent(key, () => <Demand>[]).add(item);
    }

    final List<ProductDemand> list = [];

    for (final entry in byProduct.entries) {
      final productName = entry.key;
      final productItems = entry.value;
      final sample = productItems.first;

      final pricePerKg = sample.currentPrice ?? 0.0;

      final stalls = productItems
          .map(
            (item) => StallDemand(
              stallName: item.stallName,
              kg: item.weight.toInt(),
              productId: item.productId,
              demandId: item.id,
              stallLocation: item.stallLocation,
            ),
          )
          .toList(growable: false);

      list.add(
        ProductDemand(
          title: productName,
          asset: _assetForProduct(sample),
          pricePerKg: pricePerKg,
          stalls: stalls,
        ),
      );
    }

    // Sort by title for stable order
    list.sort((a, b) => a.title.compareTo(b.title));
    return list;
  }

  /// Simple mapping from product to image asset.
  String _assetForProduct(Demand item) {
    final name = item.productName.toLowerCase();
    final variant = item.productVariant.toLowerCase();
    final combined = '$variant $name';

    if (combined.contains('green ice')) {
      return 'assets/green_ice.jpg';
    } else if (combined.contains('iceberg')) {
      return 'assets/iceberg.jpg';
    } else if (combined.contains('romaine')) {
      return 'assets/romaine.jpg';
    }

    return 'assets/romaine.jpg';
  }

  /* ==================== NAVIGATION ==================== */

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FarmerHomePage()),
    );
  }

  void _goStalls() {}

  void _goAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
  }

  void _openSupplyPage({
    required ProductDemand section,
    required StallDemand stall,
    required String farmerLocation,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmerSupplyPage(
          produceName: section.title,
          stallName: stall.stallName,
          stallLocation: stall.stallLocation,
          currentDemandKg: stall.kg,
          unitPricePerKg: section.pricePerKg,
          assetPath: section.asset,
          productId: stall.productId,
          demandId: stall.demandId,
          farmerLocation: farmerLocation,
        ),
      ),
    );
  }

  String _resolveFarmerLocation() {
    final raw = _profile?['farm_location'] as String?;
    if (raw == null) return 'Farmer location not set';
    final trimmed = raw.trim();
    return trimmed.isEmpty ? 'Farmer location not set' : trimmed;
  }

  /* ==================== BUILD ==================== */

  @override
  Widget build(BuildContext context) {
    final bool isProfileLoading = _profile == null;
    final bool isLoading = isProfileLoading || _demandLoading;

    return Scaffold(
      backgroundColor: FarmerStallsPage.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const BannerHeaderSliver(),

            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: FarmerStallsPage.primaryGreen,
                  ),
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

              if (_demandError != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      _demandError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),

              // SECTION TITLE — “Current Demand”
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Demand',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: FarmerStallsPage.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        niceNow(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SECTIONS LIST
              if (_sections.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No stall demand available right now.\nCheck again later!',
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: _sections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      final farmerLocation = _resolveFarmerLocation();

                      return DemandSection(
                        data: section,
                        onTapStall: (stall) => _openSupplyPage(
                          section: section,
                          stall: stall,
                          farmerLocation: farmerLocation,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.farmer,
        current: AppTab.middle, // highlight "Stalls"
        onHome: _goHome,
        onMiddle: _goStalls,
        onAccount: _goAccount,
      ),
    );
  }
}
