import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/product_api.dart';
import 'package:green_chain_v1/models/product.dart';
import '../../../api/auth_api.dart';
import '../../../widgets/current_price.dart';
import '../widgets/farmer_product_card.dart';
import 'farmer_stalls_page.dart';
import '../../../account_page.dart';

import '../../../ui/green_theme.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/bottom_nav.dart';

import 'package:green_chain_v1/utils/product_assets.dart';

class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});
  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  Map<String, dynamic>? _profile;
  String? _error;

  List<Product> _products = [];
  bool _loadingProducts = true;
  String? _productsError;

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
      final items = await fetchProducts();

      if (!mounted) return;
      setState(() {
        _profile = p ?? {};
        _error = null;

        _products = items;
        _loadingProducts = false;
        _productsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile ??= {};
        _error ??= 'Could not load profile';

        _products = [];
        _loadingProducts = false;
        _productsError = 'Could not load products';
      });
    }
  }

  void _goHome() {}
  void _goStalls() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const FarmerStallsPage()),
  );
  void _goAccount() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );

  @override
  Widget build(BuildContext context) {
    final loadingProfile = _profile == null;
    final loading = loadingProfile || _loadingProducts;
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

                const CurrentPriceHeader(),

                if (!hasProducts)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No products available yet.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
                        final asset = assetForProduct(p);
                        final title = '${p.variant} ${p.name}';
                        return FarmerProductCard(
                          name: title,
                          price: p.currentPrice,
                          unit: '/kg',
                          assetPath: asset,
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
        role: UserRole.farmer,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goStalls,
        onAccount: _goAccount,
      ),
    );
  }
}
