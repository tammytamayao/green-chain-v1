import 'package:flutter/material.dart';
import 'package:green_chain_v1/widgets/process_request_dialog.dart';
import '../../api/auth_api.dart';
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

// Backend data
import 'package:green_chain_v1/models/product.dart';
import 'package:green_chain_v1/api/product_api.dart' show fetchProducts;
import 'package:green_chain_v1/models/stall_inventory_item.dart';
import 'package:green_chain_v1/api/stall_inventory_api.dart'
    show fetchStallInventory, updateStallInventory, createStallInventory;
import 'package:green_chain_v1/models/demand.dart';
import 'package:green_chain_v1/api/demand_api.dart'
    show fetchDemands, createOrUpdateDemand, deleteDemand, completeDemand;

class DisposerOrdersPage extends StatefulWidget {
  const DisposerOrdersPage({super.key});

  @override
  State<DisposerOrdersPage> createState() => _DisposerOrdersPageState();
}

class _DisposerOrdersPageState extends State<DisposerOrdersPage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  int _tabIndex = 0; // 0 = Buy, 1 = Sell

  // Backend data
  List<Product> _products = [];
  bool _loadingProducts = true;

  List<StallInventoryItem> _inventory = [];
  bool _loadingInventory = true;
  String? _inventoryError;

  // Demands (buy requests)
  List<Demand> _demands = [];
  Map<int, Demand> _demandsByProductId = {};
  bool _loadingDemands = true;
  String? _demandsError;

  // Saved buy requests per item (by productId)
  final Map<int, double> _buyRequests = {};

  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await me().timeout(const Duration(seconds: 8));
      final products = await fetchProducts();
      final inventory = await fetchStallInventory();
      final demands = await fetchDemands();

      if (!mounted) return;
      setState(() {
        _profile = profile ?? {};
        _error = null;

        _products = products;
        _loadingProducts = false;

        _inventory = inventory;
        _loadingInventory = false;
        _inventoryError = null;

        _demands = demands;
        _demandsByProductId = {for (final d in demands) d.productId: d};

        _buyRequests
          ..clear()
          ..addEntries(
            // later you can filter out completed demands here if backend adds status
            demands.map((d) => MapEntry(d.productId, d.weight)),
          );

        _loadingDemands = false;
        _demandsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile ??= {};
        _error ??= 'Could not load profile';

        _products = [];
        _loadingProducts = false;

        _inventory = [];
        _loadingInventory = false;
        _inventoryError = 'Could not load inventory';

        _demands = [];
        _demandsByProductId = {};
        _buyRequests.clear();
        _loadingDemands = false;
        _demandsError ??= 'Could not load demands';
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

  // Derive image asset from product variant:
  // "Green Ice" -> assets/green_ice.jpg
  String _assetForVariant(String variant) {
    final slug = variant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return 'assets/$slug.jpg';
  }

  /// Build MarketItem list for the Buy tab
  /// - price  = product.currentPrice
  /// - available = sum(stocks) from stall_inventory for that product
  List<MarketItem> get _buyMarketItems {
    if (_products.isEmpty) return [];

    // Aggregate stocks by product_id
    final Map<int, double> stockByProduct = {};
    for (final inv in _inventory) {
      stockByProduct.update(
        inv.productId,
        (prev) => prev + inv.stocks,
        ifAbsent: () => inv.stocks,
      );
    }

    final items = <MarketItem>[];

    for (final p in _products) {
      final name = '${p.variant} ${p.name}';
      final price = p.currentPrice ?? 0.0;
      final availableKg = stockByProduct[p.id] ?? 0.0;

      items.add(
        MarketItem(
          productId: p.id,
          name: name,
          price: price,
          unit: '/kg',
          assetPath: _assetForVariant(p.variant),
          available: availableKg.round(), // integer field
        ),
      );
    }

    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  /// Build SellLot list from stall_inventory rows.
  /// Each lot corresponds to one product, with variants mapping size/type.
  List<SellLot> get _sellLotsFromInventory {
    if (_inventory.isEmpty) return [];

    // Group inventory rows by product_id
    final Map<int, List<StallInventoryItem>> byProduct = {};
    for (final item in _inventory) {
      byProduct.putIfAbsent(item.productId, () => []).add(item);
    }

    final lots = <SellLot>[];

    byProduct.forEach((productId, items) {
      if (items.isEmpty) return;

      final first = items.first;
      final name = '${first.productVariant} ${first.productName}';
      final unit = '/kg';
      final assetPath = _assetForVariant(first.productVariant);

      final variants = items.map((item) {
        // Map DB strings to enums
        final sizeStr = item.size.toLowerCase();
        final typeStr = item.type.toLowerCase();

        final sizeEnum = sizeStr.startsWith('small')
            ? LettuceSize.small
            : LettuceSize.big;

        final typeEnum = typeStr.startsWith('organic')
            ? LettuceVariantType.organic
            : LettuceVariantType.nonOrganic;

        final price = item.variantPrice ?? item.currentPrice ?? 0.0;

        return VariantPrice(
          id: item.id, // use stall_inventory.id as variant id
          size: sizeEnum,
          variantType: typeEnum,
          price: price,
          stockKg: item.stocks,
        );
      }).toList();

      lots.add(
        SellLot(
          name: name,
          unit: unit,
          assetPath: assetPath,
          status: 'Open', // could be derived later
          variants: variants,
        ),
      );
    });

    lots.sort((a, b) => a.name.compareTo(b.name));
    return lots;
  }

  // ====== Add inventory dialog ======

  Future<void> _showAddInventoryDialog() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available to add.')),
      );
      return;
    }

    final typeOptions = <String>['Organic', 'Non-organic'];
    final sizeOptions = <String>['Big', 'Small'];

    final classController = TextEditingController();
    final freshnessController = TextEditingController();
    final stocksController = TextEditingController();

    String? localError;
    bool saving = false;

    Product? selectedProduct;
    String? selectedType;
    String? selectedSize;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Add stock inventory'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      decoration: const InputDecoration(labelText: 'Product'),
                      initialValue: selectedProduct,
                      items: _products
                          .map(
                            (p) => DropdownMenuItem<Product>(
                              value: p,
                              child: Text('${p.variant} ${p.name}'),
                            ),
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
                      decoration: const InputDecoration(labelText: 'Type'),
                      initialValue: selectedType,
                      items: typeOptions
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Size'),
                      initialValue: selectedSize,
                      items: sizeOptions
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedSize = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: classController,
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        hintText: 'e.g., A, B, Premium',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: freshnessController,
                      decoration: const InputDecoration(
                        labelText: 'Freshness',
                        hintText: 'e.g., Newly harvested, 1 day old',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stocksController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Stocks (kg)',
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
                      : () => Navigator.of(ctx).pop<void>(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final klass = classController.text.trim();
                          final freshness = freshnessController.text.trim();
                          final stocksText = stocksController.text.trim();

                          if (selectedProduct == null ||
                              selectedType == null ||
                              selectedSize == null ||
                              klass.isEmpty ||
                              freshness.isEmpty ||
                              stocksText.isEmpty) {
                            setStateDialog(() {
                              localError =
                                  'Please fill in all fields and select product, type and size.';
                            });
                            return;
                          }

                          final stocks = double.tryParse(stocksText);
                          if (stocks == null || stocks <= 0) {
                            setStateDialog(() {
                              localError =
                                  'Enter a valid positive number for stocks.';
                            });
                            return;
                          }

                          setStateDialog(() {
                            saving = true;
                            localError = null;
                          });

                          try {
                            final created = await createStallInventory(
                              productId: selectedProduct!.id,
                              stocks: stocks,
                              size: selectedSize!,
                              type: selectedType!,
                              freshness: freshness,
                              itemClass: klass,
                            );

                            if (!mounted) return;

                            setState(() {
                              _inventory = [..._inventory, created];
                            });

                            if (ctx.mounted) {
                              Navigator.of(ctx).pop<void>();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock added: ${created.displayName} '
                                  '(${created.type}, ${created.size}, ${created.stocks} kg)',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            setStateDialog(() {
                              saving = false;
                              localError = 'Failed to save inventory: $e';
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
  }

  void _onAddInventory() {
    if (_loadingProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products are still loading...')),
      );
      return;
    }
    _showAddInventoryDialog();
  }

  StallInventoryItem? _findInventoryItem({
    required int productId,
    required String size,
    required String type,
  }) {
    final sizeLc = size.toLowerCase();
    final typeLc = type.toLowerCase();

    for (final inv in _inventory) {
      if (inv.productId == productId &&
          inv.size.toLowerCase() == sizeLc &&
          inv.type.toLowerCase() == typeLc) {
        return inv;
      }
    }
    return null;
  }

  Future<void> _handleProcessRequest(MarketItem item) async {
    // Get requested weight for this product
    final requestedWeight = _buyRequests[item.productId] ?? 0;
    if (requestedWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No request weight set for this item.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Open the separate dialog (scrollable, height-limited)
    final splits = await showProcessRequestDialog(
      context: context,
      item: item,
      requestedWeight: requestedWeight,
    );

    // User cancelled
    if (splits == null || splits.isEmpty) return;

    try {
      final List<StallInventoryItem> updatedOrCreated = [];

      for (final split in splits) {
        final existing = _findInventoryItem(
          productId: item.productId,
          size: split.size,
          type: split.type,
        );

        if (existing != null) {
          // update stocks
          final updated = await updateStallInventory(
            id: existing.id,
            stocks: existing.stocks + split.weight,
          );
          updatedOrCreated.add(updated);
        } else {
          // create new row
          final created = await createStallInventory(
            productId: item.productId,
            stocks: split.weight,
            size: split.size,
            type: split.type,
            // you can adjust these defaults if needed
            freshness: '90',
            itemClass: 'A',
          );
          updatedOrCreated.add(created);
        }
      }

      // 👉 Find the demand tied to this product
      final demand = _demandsByProductId[item.productId];

      // 👉 Mark its requests as completed + remove demand on backend
      if (demand != null) {
        await completeDemand(demand.id);
      }

      if (!mounted) return;

      setState(() {
        // merge updated/created into _inventory
        for (final it in updatedOrCreated) {
          final idx = _inventory.indexWhere((e) => e.id == it.id);
          if (idx == -1) {
            _inventory.add(it);
          } else {
            _inventory[idx] = it;
          }
        }

        // Clear active request so UI goes back to "Request" button
        _buyRequests.remove(item.productId);

        // Remove from local demands so this item is no longer "processing"
        if (demand != null) {
          _demandsByProductId.remove(item.productId);
          _demands.removeWhere((d) => d.id == demand.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Processed request for ${item.name} into stall inventory.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process request: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingProfile = _profile == null;
    final loading =
        loadingProfile ||
        _loadingProducts ||
        _loadingInventory ||
        _loadingDemands;

    final marketItems = _buyMarketItems;
    final sellLots = _sellLotsFromInventory;
    final Map<int, bool> processingByProductId = {
      for (final d in _demands) d.productId: d.requestsCount > 0,
    };

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
                if (_demandsError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        _demandsError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ),

                OrdersHeaderSliver(dateText: _niceNow()),

                OrdersSegmentSwitchSliver(
                  tabIndex: _tabIndex,
                  onTabChanged: (idx) => setState(() => _tabIndex = idx),
                ),

                // BUY TAB
                if (_tabIndex == 0)
                  (marketItems.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(
                            icon: Icons.shopping_basket_outlined,
                            title: 'No products can be requested yet',
                            message:
                                'Add items to inventory so you can manage requests from farmers.',
                          ),
                        )
                      : BuyTabSliver(
                          items: marketItems,
                          buyRequests: _buyRequests,
                          processingByProductId: processingByProductId,
                          onSaveRequest: (item, value) async {
                            try {
                              final demand = await createOrUpdateDemand(
                                productId: item.productId,
                                weight: value,
                              );

                              if (!mounted) return;
                              setState(() {
                                _buyRequests[item.productId] = demand.weight;
                                _demandsByProductId[item.productId] = demand;

                                final idx = _demands.indexWhere(
                                  (d) => d.id == demand.id,
                                );
                                if (idx == -1) {
                                  _demands.add(demand);
                                } else {
                                  _demands[idx] = demand;
                                }
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Saved request: ${value.toStringAsFixed(2)} kg of ${item.name}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save request: $e'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onDeleteRequest: (item) async {
                            final demand = _demandsByProductId[item.productId];
                            if (demand == null) return;

                            try {
                              await deleteDemand(demand.id);

                              if (!mounted) return;
                              setState(() {
                                _buyRequests.remove(item.productId);
                                _demandsByProductId.remove(item.productId);
                                _demands.removeWhere((d) => d.id == demand.id);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Deleted request for ${item.name}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete request: $e'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onProcessRequest: _handleProcessRequest,
                        ))
                // SELL TAB
                else
                  (sellLots.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'Nothing to sell yet',
                            message:
                                'Add stocks to your inventory so buyers can see your offers.',
                          ),
                        )
                      : SellTabSliver(
                          items: sellLots,
                          onUpdateVariantPrice: (lot, variant, newPrice) {
                            // We treat variant.id as stall_inventory.id
                            final invId = variant.id;

                            updateStallInventory(id: invId, price: newPrice)
                                .then((updated) {
                                  if (!mounted) return;
                                  setState(() {
                                    final idx = _inventory.indexWhere(
                                      (it) => it.id == updated.id,
                                    );
                                    if (idx != -1) {
                                      _inventory[idx] = updated;
                                    }
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
                                })
                                .catchError((e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update price: $e',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                });
                          },
                        )),
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

      // ✅ FAB only on SELL tab (tabIndex == 1), like your original code
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              onPressed: _onAddInventory,
              backgroundColor: primaryGreen,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
