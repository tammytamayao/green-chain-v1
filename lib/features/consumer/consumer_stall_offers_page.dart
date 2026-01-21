import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';

import 'product_selection.dart';
import 'consumer_create_order_page.dart';

// API + model
import 'package:green_chain_v1/api/stall_inventory_api.dart'
    show fetchStallInventory;
import 'package:green_chain_v1/models/stall_inventory_item.dart';

class ConsumerStallOffersPage extends StatefulWidget {
  const ConsumerStallOffersPage({super.key, required this.selection});

  final ProductSelection selection;

  @override
  State<ConsumerStallOffersPage> createState() =>
      _ConsumerStallOffersPageState();
}

class _ConsumerStallOffersPageState extends State<ConsumerStallOffersPage> {
  bool _loading = true;
  String? _error;
  List<StallInventoryItem> _allInventory = [];

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
      final inv = await fetchStallInventory();
      if (!mounted) return;
      setState(() {
        _allInventory = inv;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load stalls: $e';
        _allInventory = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;

    // Filter by selected product + size + type, and only stalls with stock
    final filtered = _allInventory.where((item) {
      final sameProduct = item.productId == selection.productId;
      final sameSize = item.size.toLowerCase() == selection.size.toLowerCase();
      final sameType = item.type.toLowerCase() == selection.type.toLowerCase();
      final hasStock = item.stocks > 0;
      return sameProduct && sameSize && sameType && hasStock;
    }).toList();

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      appBar: AppBar(
        backgroundColor: GreenTheme.softBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Stalls',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection.productLabel,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: GreenTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${selection.size} • ${selection.type}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: GreenTheme.primary),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No stalls available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'There are currently no stalls offering this product\n'
                            'with the selected size and type.\n\n'
                            'You can try a different combination or check again later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final stallName = item.stallName;
                      // If your StallInventoryItem doesn't yet expose stallLocation,
                      // add it to the model (mapped from "stall_location").
                      final stallLocation = item.stallLocation ?? '';
                      final price =
                          item.variantPrice ?? item.currentPrice ?? 0.0;
                      final stocks = item.stocks;

                      return _StallOfferCard(
                        name: stallName,
                        location: stallLocation,
                        price: price,
                        stocks: stocks,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConsumerCreateOrderPage(
                                stallInventoryId: item.id, // 👈 key link
                                productLabel: selection.productLabel,
                                size: selection.size,
                                type: selection.type,
                                stallName: stallName,
                                stallLocation: stallLocation,
                                unitPricePerKg: price,
                                maxStocksKg: stocks,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StallOfferCard extends StatelessWidget {
  const _StallOfferCard({
    required this.name,
    required this.location,
    required this.price,
    required this.stocks,
    required this.onTap,
  });

  final String name;
  final String location;
  final double price;
  final double stocks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
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
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '₱${price.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: GreenTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location.isEmpty ? 'Market stall' : location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Available Stocks: ${stocks.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
