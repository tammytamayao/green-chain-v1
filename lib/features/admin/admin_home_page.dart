import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/admin/admin_monitoring_page.dart';
import 'package:green_chain_v1/features/admin/admin_api.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;
  static const chipGreen = Color(0xFF4F7652);

  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _loading = false;
        _error = 'Could not load products: $e';
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

  Future<void> _showEditPriceDialog(Product product) async {
    final controller = TextEditingController(
      text: product.currentPrice?.toStringAsFixed(2) ?? '',
    );
    String? localError;

    final newPrice = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text('${product.variant} ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price (₱)'),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      localError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) {
                      setStateDialog(
                        () => localError = 'Price cannot be empty',
                      );
                      return;
                    }
                    final value = double.tryParse(text);
                    if (value == null || value < 0) {
                      setStateDialog(
                        () => localError = 'Enter a valid non-negative number',
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(value);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newPrice == null) return; // cancelled

    try {
      final updated = await updateProductPrice(product.id, newPrice);
      if (!mounted) return;
      setState(() {
        final idx = _products.indexWhere((p) => p.id == updated.id);
        if (idx != -1) {
          _products[idx] = updated;
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Price updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update price: $e')));
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: Text(
            'Are you sure you want to delete "${product.variant} ${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await deleteProduct(product.id);
      if (!mounted) return;
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
    }
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final variantController = TextEditingController();
    final priceController = TextEditingController();

    String? localError;
    bool saving = false;

    final Product? newProduct = await showDialog<Product>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Add product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: variantController,
                      decoration: const InputDecoration(
                        labelText: 'Variant',
                        hintText: 'e.g., Green Ice, Romaine',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Initial price in PHP (₱)',
                      ),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        localError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(ctx).pop<Product?>(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final variant = variantController.text.trim();
                          final priceText = priceController.text.trim();

                          if (name.isEmpty || variant.isEmpty) {
                            setStateDialog(() {
                              localError =
                                  'Please enter both product name and variant.';
                            });
                            return;
                          }

                          double? price;
                          if (priceText.isNotEmpty) {
                            price = double.tryParse(priceText);
                            if (price == null || price < 0) {
                              setStateDialog(() {
                                localError =
                                    'Enter a valid non-negative price or leave it empty.';
                              });
                              return;
                            }
                          }

                          setStateDialog(() {
                            saving = true;
                            localError = null;
                          });

                          try {
                            final created = await createProduct(
                              name: name,
                              variant: variant,
                              currentPrice: price,
                            );
                            if (!mounted) return;
                            Navigator.of(ctx).pop<Product>(created);
                          } catch (e) {
                            if (!mounted) return;
                            setStateDialog(() {
                              saving = false;
                              localError = 'Failed to create product: $e';
                            });
                          }
                        },
                  child: Text(saving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newProduct != null && mounted) {
      setState(() {
        _products = [..._products, newProduct];
        _products.sort((a, b) {
          final nameCmp = a.name.compareTo(b.name);
          if (nameCmp != 0) return nameCmp;
          return a.variant.compareTo(b.variant);
        });
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product added')));
    }
  }

  Future<void> _goAddProduct() => _showAddProductDialog();

  void _goHome() {
    // already here
  }

  void _goMonitoring() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminMonitoringPage()),
    );
  }

  void _goAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
  }

  /// Build asset path from variant:
  /// "Green Ice" -> "assets/green_ice.jpg"
  String _assetForProduct(Product p) {
    final slug = p.variant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return 'assets/$slug.jpg';
  }

  @override
  Widget build(BuildContext context) {
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

              if (_loading)
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

                // Header (similar to FarmerHomePage)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Price',
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
                      ],
                    ),
                  ),
                ),

                if (!hasProducts)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_florist_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding your first product.\nFarmers and disposers will see these prices.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _goAddProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                        return _AdminProductCard(
                          product: p,
                          assetPath: _assetForProduct(p),
                          onEdit: () => _showEditPriceDialog(p),
                          onDelete: () => _confirmDelete(p),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: hasProducts
          ? FloatingActionButton(
              backgroundColor: primaryGreen,
              onPressed: _goAddProduct,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNav(
        // Still using farmer visuals; if you add UserRole.admin later, swap this.
        role: UserRole.farmer,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goMonitoring,
        onAccount: _goAccount,
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  const _AdminProductCard({
    required this.product,
    required this.assetPath,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final String assetPath;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const chipGreen = _AdminHomePageState.chipGreen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final title = '${product.variant} ${product.name}';
    final price = product.currentPrice;
    final priceText = price == null
        ? 'No price set'
        : '₱${price.toStringAsFixed(2)} /kg';

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
          children: [
            // Background image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Icon(
                        Icons.local_florist_outlined,
                        size: 48,
                        color: GreenTheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top-right delete icon
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom info bar: name/variant + price + edit icon
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: chipGreen.withAlpha((0.97 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Big title (variant + name)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price + edit icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                priceText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: onEdit,
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
