import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/product_api.dart';
import 'package:green_chain_v1/models/product.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/admin/admin_monitoring_page.dart';
import 'package:green_chain_v1/utils/product_assets.dart';
import 'package:green_chain_v1/widgets/current_price.dart';
import 'widgets/admin_product_card.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;

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

    if (newPrice == null) return;

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
    final priceController = TextEditingController();

    String? localError;
    bool saving = false;

    // Dropdown options
    const productOptions = ['Lettuce'];
    const variantOptions = ['Green Ice', 'Iceberg', 'Romaine'];

    // Selected values
    String? selectedProduct = productOptions.first;
    String? selectedVariant = variantOptions.first;

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
                    DropdownButtonFormField<String>(
                      initialValue: selectedProduct,
                      decoration: const InputDecoration(labelText: 'Product'),
                      items: productOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedProduct = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedVariant,
                      decoration: const InputDecoration(labelText: 'Variant'),
                      items: variantOptions
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedVariant = value;
                        });
                      },
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
                          final priceText = priceController.text.trim();

                          if (selectedProduct == null ||
                              selectedVariant == null) {
                            setStateDialog(() {
                              localError =
                                  'Please select both product and variant.';
                            });
                            return;
                          }

                          // 🛑 DUPLICATE CHECK: same name + variant already exists
                          final alreadyExists = _products.any(
                            (p) =>
                                p.name.toLowerCase() ==
                                    selectedProduct!.toLowerCase() &&
                                p.variant.toLowerCase() ==
                                    selectedVariant!.toLowerCase(),
                          );

                          if (alreadyExists) {
                            setStateDialog(() {
                              localError = 'This product already exists.';
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
                              name: selectedProduct!,
                              variant: selectedVariant!,
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

  void _goHome() {}
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

                const CurrentPriceHeader(),

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
                            'Start by adding your first product.\n'
                            'Farmers and disposers will see these prices.',
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
                        return AdminProductCard(
                          product: p,
                          assetPath: assetForProduct(p),
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
        role: UserRole.admin,
        current: AppTab.home,
        onHome: _goHome,
        onMiddle: _goMonitoring,
        onAccount: _goAccount,
      ),
    );
  }
}
