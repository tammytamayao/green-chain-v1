import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/consumer/consumer_home_page.dart';

import 'product_selection.dart';
import 'consumer_stall_offers_page.dart';

class ConsumerOrdersPage extends StatelessWidget {
  const ConsumerOrdersPage({super.key});

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

  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConsumerHomePage()),
    );
  }

  void _goAccount(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
  }

  Future<void> _addOrder(BuildContext context) async {
    // Sample product list: in real app, fetch from backend
    final products = [
      {'id': 1, 'name': 'Lettuce', 'variant': 'Green Ice'},
      {'id': 2, 'name': 'Lettuce', 'variant': 'Iceberg'},
      {'id': 3, 'name': 'Lettuce', 'variant': 'Romaine'},
    ];

    const sizes = ['Small', 'Big'];
    const types = ['Organic', 'Non-organic'];

    int? selectedProductId;
    String? selectedSize;
    String? selectedType;
    String? localError;

    final selection = await showDialog<ProductSelection>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Create Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Product'),
                      initialValue: selectedProductId,
                      items: products.map((p) {
                        final label = '${p['variant']} ${p['name']}';
                        return DropdownMenuItem<int>(
                          value: p['id'] as int,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          selectedProductId = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Size dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Size'),
                      initialValue: selectedSize,
                      items: sizes.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          selectedSize = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Type dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      initialValue: selectedType,
                      items: types.map((t) {
                        return DropdownMenuItem<String>(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          selectedType = v;
                        });
                      },
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
                  onPressed: () =>
                      Navigator.of(ctx).pop<ProductSelection?>(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedProductId == null ||
                        selectedSize == null ||
                        selectedType == null) {
                      setStateDialog(() {
                        localError = 'Please select product, size, and type.';
                      });
                      return;
                    }

                    final product = products.firstWhere(
                      (p) => p['id'] == selectedProductId,
                    );
                    final label = '${product['variant']} ${product['name']}';

                    Navigator.of(ctx).pop<ProductSelection>(
                      ProductSelection(
                        productId: selectedProductId!,
                        productLabel: label,
                        size: selectedSize!,
                        type: selectedType!,
                      ),
                    );
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selection == null) return; // cancelled

    // Navigate to stall offers page with that selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsumerStallOffersPage(selection: selection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For now, static sample orders
    final List<Map<String, dynamic>> orders = [
      {
        'title': 'Green Ice Lettuce',
        'subtitle': '2 kg from Stall #5',
        'amount': 120.00,
      },
      {
        'title': 'Romaine Lettuce',
        'subtitle': '1.5 kg from Stall #3',
        'amount': 90.00,
      },
      {
        'title': 'Iceberg Lettuce',
        'subtitle': '3 kg from Stall #2',
        'amount': 150.00,
      },
      {
        'title': 'Butterhead Lettuce',
        'subtitle': '0.8 kg from Stall #1',
        'amount': 50.00,
      },
    ];

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BannerHeaderSliver(),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: GreenTheme.primary,
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
            ),

            if (orders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You haven\'t placed any orders yet.\nTap the + button to create your first order.',
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
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(
                      title: order['title'] as String,
                      subtitle: order['subtitle'] as String,
                      amount: order['amount'] as double,
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: GreenTheme.primary,
        onPressed: () => _addOrder(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNav(
        role: UserRole.farmer, // reuse visuals for now
        current: AppTab.middle,
        onHome: () => _goHome(context),
        onMiddle: () {},
        onAccount: () => _goAccount(context),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
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
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GreenTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: GreenTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₱${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
