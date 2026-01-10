// lib/features/consumer/consumer_stall_offers_page.dart
import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';

import 'product_selection.dart';
import 'consumer_create_order_page.dart';

class ConsumerStallOffersPage extends StatelessWidget {
  const ConsumerStallOffersPage({super.key, required this.selection});

  final ProductSelection selection;

  @override
  Widget build(BuildContext context) {
    // For now: sample stalls. Later, fetch from backend by productId/size/type.
    final stalls = [
      {
        'name': 'Stall 5 - Fresh Greens',
        'location': 'Section A • Row 2',
        'price': 60.0,
        'stocks': 25.0,
      },
      {
        'name': 'Stall 3 - Lettuce Hub',
        'location': 'Section B • Row 1',
        'price': 58.0,
        'stocks': 18.0,
      },
      {
        'name': 'Stall 2 - Organic Corner',
        'location': 'Section C • Row 4',
        'price': 62.0,
        'stocks': 30.0,
      },
    ];

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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Selected product header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selection.productLabel,
                      style: const TextStyle(
                        fontSize: 24, // bigger
                        fontWeight: FontWeight.w800,
                        color: GreenTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${selection.size} • ${selection.type}',
                      style: TextStyle(
                        fontSize: 16, // more prominent
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (stalls.isEmpty)
              // Centered empty state (vertically & horizontally)
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
                  itemCount: stalls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = stalls[index];
                    final name = s['name'] as String;
                    final location = s['location'] as String;
                    final price = s['price'] as double;
                    final stocks = s['stocks'] as double;

                    return _StallOfferCard(
                      name: name,
                      location: location,
                      price: price,
                      stocks: stocks,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConsumerCreateOrderPage(
                              productLabel: selection.productLabel,
                              size: selection.size,
                              type: selection.type,
                              stallName: name,
                              stallLocation: location,
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
                // Stall name + price
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
                // Location
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
                        location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Stocks
                Text(
                  'Stocks: ${stocks.toStringAsFixed(1)} kg',
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
