import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/order_api.dart';
import 'package:green_chain_v1/models/order.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/consumer/consumer_home_page.dart';

import 'product_selection.dart';
import 'consumer_stall_offers_page.dart';

class ConsumerOrdersPage extends StatefulWidget {
  const ConsumerOrdersPage({super.key});

  @override
  State<ConsumerOrdersPage> createState() => _ConsumerOrdersPageState();
}

class _ConsumerOrdersPageState extends State<ConsumerOrdersPage> {
  bool _loading = true;
  String? _error;
  List<ConsumerOrder> _orders = [];

  // ✅ track which orders are being "received"
  final Set<int> _receivingIds = {};

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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders = await fetchOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load orders: $e';
        _orders = [];
      });
    }
  }

  // ✅ mark order as received -> completed
  Future<void> _receiveOrder(ConsumerOrder order) async {
    final id = order.id;
    if (_receivingIds.contains(id)) return;

    setState(() {
      _receivingIds.add(id);
    });

    try {
      // ✅ uses your new endpoint PATCH /orders/<id>/receive
      final updated = await receiveOrder(orderId: id);

      if (!mounted) return;

      setState(() {
        final idx = _orders.indexWhere((o) => o.id == id);
        if (idx != -1) _orders[idx] = updated;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order marked as received')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to receive order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _receivingIds.remove(id);
        });
      }
    }
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
    // TODO: Replace this with real products from backend (fetchProducts()).
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Size'),
                      initialValue: selectedSize,
                      items: sizes
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          selectedSize = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      initialValue: selectedType,
                      items: types
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ),
                          )
                          .toList(),
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

    if (selection == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsumerStallOffersPage(selection: selection),
      ),
    );

    // Refresh after returning from order flow
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOrders,
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
              else if (orders.isEmpty)
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
                      final title = order.fullProductLabel;
                      final qty = order.weight;
                      final subtitle =
                          '${qty.toStringAsFixed(1)} kg from ${order.stallName}';

                      final showReceive = order.status == 'accepted';
                      final receiving = _receivingIds.contains(order.id);

                      return _OrderCard(
                        title: title,
                        subtitle: subtitle,
                        amount: order.amount,
                        statusLabel: order.statusLabel,
                        statusRaw: order.status,
                        showReceiveButton: showReceive,
                        receiving: receiving,
                        onReceive: () => _receiveOrder(order),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GreenTheme.primary,
        onPressed: () => _addOrder(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNav(
        role: UserRole.consumer,
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
    required this.statusLabel,
    required this.statusRaw,
    required this.showReceiveButton,
    required this.receiving,
    required this.onReceive,
  });

  final String title;
  final String subtitle;
  final double amount;

  final String statusLabel;
  final String statusRaw;

  final bool showReceiveButton;
  final bool receiving;
  final VoidCallback onReceive;

  Color _statusColor() {
    switch (statusRaw) {
      case 'processing':
        return Colors.orange.shade700;
      case 'accepted':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'rejected':
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final statusColor = _statusColor();

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ✅ If accepted -> show Receive button. Otherwise -> show status pill.
                  if (showReceiveButton)
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GreenTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: receiving ? null : onReceive,
                        child: receiving
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Receive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
