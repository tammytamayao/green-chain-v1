import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/order_api.dart';
import 'package:green_chain_v1/api/auth_api.dart' as auth_api; // 👈 NEW
import 'package:green_chain_v1/ui/green_theme.dart';

// Reuse farmer widgets for identical design
import 'package:green_chain_v1/widgets/farmers/order_summary_card.dart';
import 'package:green_chain_v1/widgets/farmers/payment_card.dart';
import 'package:green_chain_v1/widgets/farmers/delivery_approach_card.dart';
import 'package:green_chain_v1/utils/farmer/cart_constants.dart';

// consumer confirmation + rejected sheet
import 'package:green_chain_v1/features/consumer/consumer_order_confirmation_page.dart';
import 'package:green_chain_v1/features/consumer/consumer_order_rejected_bottom_sheet.dart';

// Payment mapping util (same as farmer)
import 'package:green_chain_v1/utils/farmer/payment_method_to_api.dart';

class ConsumerCreateOrderPage extends StatefulWidget {
  const ConsumerCreateOrderPage({
    super.key,
    required this.stallInventoryId,
    required this.productLabel,
    required this.size,
    required this.type,
    required this.stallName,
    required this.stallLocation,
    required this.unitPricePerKg,
    required this.maxStocksKg,
  });

  final int stallInventoryId;

  final String productLabel;
  final String size;
  final String type;
  final String stallName;
  final String stallLocation;
  final double unitPricePerKg;
  final double maxStocksKg;

  @override
  State<ConsumerCreateOrderPage> createState() =>
      _ConsumerCreateOrderPageState();
}

class _ConsumerCreateOrderPageState extends State<ConsumerCreateOrderPage> {
  int qtyKg = 1;

  DeliveryApproach deliveryApproach = DeliveryApproach.deliverRightAway;
  PaymentMethod paymentMethod = PaymentMethod.gcash;

  bool _isSubmitting = false;

  String? _consumerAddress; // 👈 loaded from /me

  double get _subtotal => qtyKg * widget.unitPricePerKg;
  double get _deliveryFee => 20.0; // placeholder
  double get _total => _subtotal + _deliveryFee;

  @override
  void initState() {
    super.initState();
    if (widget.maxStocksKg <= 0) {
      qtyKg = 0;
    }
    _loadConsumerInfo(); // 👈 fetch /me for address
  }

  Future<void> _loadConsumerInfo() async {
    try {
      final info = await auth_api.me();
      if (!mounted) return;
      setState(() {
        _consumerAddress = info?['address'] as String?;
      });
    } catch (_) {
      // If /me fails, just fall back to a generic label
    }
  }

  void _decQty() {
    setState(() {
      if (qtyKg > 1) qtyKg--;
    });
  }

  void _incQty() {
    setState(() {
      if (qtyKg < widget.maxStocksKg.round()) {
        qtyKg++;
      }
    });
  }

  String get _deliveryApproachLabel {
    switch (deliveryApproach) {
      case DeliveryApproach.deliverRightAway:
        return 'Deliver right away';
      case DeliveryApproach.helpDelivery:
        return 'Help Delivery';
    }
  }

  String get _paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.gcash:
        return 'Gcash';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get _arrivalText {
    switch (deliveryApproach) {
      case DeliveryApproach.deliverRightAway:
        return 'Within the next 1–2 days';
      case DeliveryApproach.helpDelivery:
        return 'Within the next 1–2 days (with delivery assistance)';
    }
  }

  /// 👇 Pickup is from the stall
  String get _pickupLocation => widget.stallLocation;

  /// 👇 Delivery is to the consumer address
  String get _deliveryLocation {
    // If address not loaded / not set, show a fallback
    return _consumerAddress ?? 'No saved address yet';
  }

  Future<void> _placeOrder() async {
    if (qtyKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity to order.')),
      );
      return;
    }

    if (qtyKg > widget.maxStocksKg) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requested quantity exceeds available stocks.'),
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    final methodStr = paymentMethodToApi(paymentMethod); // "gcash" | "cash"

    setState(() {
      _isSubmitting = true;
    });

    try {
      await createOrder(
        stallInventoryId: widget.stallInventoryId,
        amount: _total,
        method: methodStr,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConsumerOrderConfirmationPage(
            productName: widget.productLabel,
            stallName: widget.stallName,
            qtyKg: qtyKg,
            totalAmount: _total,
            arrivalText: _arrivalText,
            pickupLocation: _pickupLocation, // 👈 from stall
            deliveryLocation: _deliveryLocation, // 👈 from consumer address
            deliveryApproachLabel: _deliveryApproachLabel,
            paymentMethodLabel: _paymentMethodLabel,
            buttonText: 'Back to Home',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      await showOrderRejectedBottomSheet(
        context: context,
        productName: widget.productLabel,
        stallName: widget.stallName,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = widget.maxStocksKg;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      appBar: AppBar(
        backgroundColor: GreenTheme.softBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            _OrderHeader(
              productLabel: widget.productLabel,
              stallName: widget.stallName,
              stallLocation: widget.stallLocation,
              size: widget.size,
              type: widget.type,
            ),
            const SizedBox(height: 10),
            _QuantityCard(
              qtyKg: qtyKg,
              maxStocksKg: maxQty,
              unitPricePerKg: widget.unitPricePerKg,
              onDec: _decQty,
              onInc: _incQty,
            ),
            const SizedBox(height: 10),
            OrderSummaryCard(
              qtyKg: qtyKg,
              unitPricePerKg: widget.unitPricePerKg,
              subtotal: _subtotal,
              delivery: _deliveryFee,
              total: _total,
            ),
            const SizedBox(height: 12),
            DeliveryApproachCard(
              value: deliveryApproach,
              onChanged: (v) => setState(() => deliveryApproach = v),
            ),
            const SizedBox(height: 10),
            PaymentCard(
              value: paymentMethod,
              onChanged: (v) => setState(() => paymentMethod = v),
            ),
            const SizedBox(height: 14),
            _PlaceOrderButton(
              enabled: !_isSubmitting && qtyKg > 0 && maxQty > 0,
              onPressed: _placeOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.productLabel,
    required this.stallName,
    required this.stallLocation,
    required this.size,
    required this.type,
  });

  final String productLabel;
  final String stallName;
  final String stallLocation;
  final String size;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productLabel,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: GreenTheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$size • $type',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                stallName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                stallLocation,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard({
    required this.qtyKg,
    required this.maxStocksKg,
    required this.unitPricePerKg,
    required this.onDec,
    required this.onInc,
  });

  final int qtyKg;
  final double maxStocksKg;
  final double unitPricePerKg;
  final VoidCallback onDec;
  final VoidCallback onInc;

  bool get _noStock => maxStocksKg <= 0;

  @override
  Widget build(BuildContext context) {
    final canDecrease = qtyKg > 1;
    final canIncrease = qtyKg < maxStocksKg.round() && maxStocksKg > 0;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // LEFT: text & price chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order quantity',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _noStock
                        ? 'No stocks available'
                        : 'Available: ${maxStocksKg.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: _noStock
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                      fontWeight: _noStock ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CartConstants.chipGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₱${unitPricePerKg.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT: quantity controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  onPressed: canDecrease ? onDec : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                const SizedBox(width: 4),
                Text(
                  '$qtyKg kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _noStock
                        ? Colors.grey.shade500
                        : CartConstants.chipGreen,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  onPressed: canIncrease ? onInc : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? GreenTheme.primary : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(
          enabled ? 'Place Order' : 'Set Quantity',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
