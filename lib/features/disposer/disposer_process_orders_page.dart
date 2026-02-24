// lib/features/disposer/.../disposer_process_orders_page.dart

import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/account_page.dart';
import 'disposer_home_page.dart';

import 'package:green_chain_v1/api/order_api.dart';
import 'package:green_chain_v1/models/order.dart';
import 'package:green_chain_v1/models/order_status_update_response.dart';

class DisposerProcessOrdersPage extends StatefulWidget {
  const DisposerProcessOrdersPage({super.key});

  @override
  State<DisposerProcessOrdersPage> createState() =>
      _DisposerProcessOrdersPageState();
}

class _DisposerProcessOrdersPageState extends State<DisposerProcessOrdersPage> {
  bool _loading = true;
  String? _error;
  List<ConsumerOrder> _orders = [];

  final Set<int> _updatingIds = {};

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

  Future<void> _setOrderStatus({
    required ConsumerOrder order,
    required String nextStatus, // "accepted" | "rejected"
  }) async {
    final orderId = order.id;
    if (_updatingIds.contains(orderId)) return;

    setState(() {
      _updatingIds.add(orderId);
    });

    try {
      final OrderStatusUpdateResponse resp = await updateOrderStatus(
        orderId: orderId,
        status: nextStatus,
      );

      if (!mounted) return;

      setState(() {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) _orders[idx] = resp.order;
      });

      final baseMsg = nextStatus == 'accepted'
          ? 'Order accepted'
          : 'Order rejected';

      // ✅ delivery will be created on accept (backend)
      final deliveryMsg = (nextStatus == 'accepted' && resp.delivery != null)
          ? ' • Delivery created (#${resp.delivery!.id})'
          : '';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$baseMsg$deliveryMsg')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(orderId);
        });
      }
    }
  }

  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DisposerHomePage()),
    );
  }

  void _goAccount(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      appBar: AppBar(
        backgroundColor: GreenTheme.softBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Process Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Orders',
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
                            Icons.playlist_add_check_circle_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No orders to process',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Once consumers place orders from your stall,\n'
                            'they will appear here so you can process them.',
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

                      final qtyText = '${order.weight.toStringAsFixed(1)} kg';

                      final title = order.fullProductLabel;
                      final subtitle = [
                        qtyText,
                        'Method: ${order.method.toUpperCase()}',
                        'From: ${order.stallName}',
                      ].join(' • ');

                      final isProcessing = order.status == 'processing';
                      final isUpdating = _updatingIds.contains(order.id);

                      return _ProcessOrderCard(
                        title: title,
                        subtitle: subtitle,
                        amount: order.amount,
                        statusLabel: order.statusLabel,
                        statusRaw: order.status,
                        showDecisionButtons: isProcessing,
                        updating: isUpdating,
                        onAccept: () => _setOrderStatus(
                          order: order,
                          nextStatus: 'accepted',
                        ),
                        onReject: () => _setOrderStatus(
                          order: order,
                          nextStatus: 'rejected',
                        ),
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

class _ProcessOrderCard extends StatelessWidget {
  const _ProcessOrderCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.statusLabel,
    required this.statusRaw,
    required this.showDecisionButtons,
    required this.updating,
    required this.onAccept,
    required this.onReject,
  });

  final String title;
  final String subtitle;
  final double amount;
  final String statusLabel;
  final String statusRaw;

  final bool showDecisionButtons;
  final bool updating;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  Color _statusColor() {
    switch (statusRaw) {
      case 'processing':
        return Colors.orange.shade600;
      case 'accepted':
        return Colors.blue.shade600;
      case 'completed':
        return Colors.green.shade700;
      case 'rejected':
      case 'cancelled':
        return Colors.red.shade600;
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
                  Icons.playlist_add_check,
                  color: GreenTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 10),

                    if (showDecisionButtons)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GreenTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: updating ? null : onAccept,
                                child: updating
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Accept',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red.shade600),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: updating ? null : onReject,
                                child: updating
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red.shade600,
                                        ),
                                      )
                                    : Text(
                                        'Reject',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
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
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
