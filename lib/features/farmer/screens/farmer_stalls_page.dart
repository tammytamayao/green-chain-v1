import 'package:flutter/material.dart';

import 'package:green_chain_v1/utils/date_utils.dart';
import 'package:green_chain_v1/api/auth_api.dart';
import 'package:green_chain_v1/api/demand_api.dart';
import 'package:green_chain_v1/models/demand.dart';

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
  List<_ProductDemand> _sections = const [];

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
  List<_ProductDemand> _buildSectionsFromDemands(List<Demand> items) {
    final Map<String, List<Demand>> byProduct = {};

    for (final item in items) {
      final key = item.displayName.trim(); // e.g. "<variant> <name>"
      byProduct.putIfAbsent(key, () => <Demand>[]).add(item);
    }

    final List<_ProductDemand> list = [];

    for (final entry in byProduct.entries) {
      final productName = entry.key;
      final productItems = entry.value;
      final sample = productItems.first;

      final pricePerKg = sample.currentPrice ?? 0.0;

      final stalls = productItems
          .map(
            (item) => _StallDemand(
              stallName: item.stallName,
              kg: item.weight.toInt(),
              productId: item.productId,
              demandId: item.id,
              stallLocation: item.stallLocation, // 👈 NEW
            ),
          )
          .toList(growable: false);

      list.add(
        _ProductDemand(
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

    // default / fallback image
    return 'assets/romaine.jpg';
  }

  /* ==================== NAVIGATION ==================== */

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FarmerHomePage()),
    );
  }

  void _goStalls() {
    // already on this tab – no-op
  }

  void _goAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
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
                      final farmerLocation =
                          (_profile?['farm_location'] as String?)
                                  ?.trim()
                                  .isNotEmpty ==
                              true
                          ? (_profile!['farm_location'] as String).trim()
                          : 'Farmer location not set';

                      return _DemandSection(
                        data: section,
                        farmerLocation: farmerLocation, // ✅ pass in
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

/* ==================== INTERNAL VIEW MODELS ==================== */

class _ProductDemand {
  const _ProductDemand({
    required this.title,
    required this.asset,
    required this.pricePerKg,
    required this.stalls,
  });

  final String title;
  final String asset;
  final double pricePerKg;
  final List<_StallDemand> stalls;
}

class _StallDemand {
  const _StallDemand({
    required this.stallName,
    required this.kg,
    required this.productId,
    required this.demandId,
    required this.stallLocation, // 👈 NEW
  });

  final String stallName;
  final int kg;
  final int productId;
  final int demandId;
  final String stallLocation; // 👈 NEW
}

/* ==================== WIDGETS ==================== */

class _DemandSection extends StatelessWidget {
  const _DemandSection({required this.data, required this.farmerLocation});

  final _ProductDemand data;
  final String farmerLocation;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = FarmerStallsPage.primaryGreen;
    const chipBg = FarmerStallsPage.chipBg;

    const titleStyle = TextStyle(
      color: primaryGreen,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: 0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product header (product name)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: primaryGreen.withAlpha((0.25 * 255).round()),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text(data.title, style: titleStyle)),
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stalls + kg list
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  for (final stall in data.stalls)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FarmerSupplyPage(
                                produceName: data.title,
                                stallName: stall.stallName,
                                stallLocation: stall.stallLocation,
                                currentDemandKg: stall.kg,
                                unitPricePerKg: data.pricePerKg,
                                assetPath: data.asset,
                                productId: stall.productId,
                                demandId: stall.demandId,
                                farmerLocation: farmerLocation,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.05 * 255).round(),
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${stall.stallName}: ${stall.kg}kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Circular image preview (product picture)
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: primaryGreen.withAlpha((0.25 * 255).round()),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.04 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(
                        data.asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/romaine.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
