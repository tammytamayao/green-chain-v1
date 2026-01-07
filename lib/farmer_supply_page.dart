import 'package:flutter/material.dart';
import 'home_farmer.dart';

import 'ui/green_theme.dart';

import 'supply_confirmation_page.dart';
import 'supply_rejected_page.dart';

enum DeliveryApproach { deliverRightAway, helpDelivery }

enum PaymentMethod { gcash, cash }

class FarmerSupplyPage extends StatefulWidget {
  const FarmerSupplyPage({
    super.key,
    required this.produceName,
    required this.stallName,
    required this.currentDemandKg,
    required this.unitPricePerKg,
    required this.assetPath,
  });

  final String produceName;
  final String stallName;
  final int currentDemandKg;
  final double unitPricePerKg;
  final String assetPath;

  @override
  State<FarmerSupplyPage> createState() => _FarmerSupplyPageState();
}

class _FarmerSupplyPageState extends State<FarmerSupplyPage> {
  late int qtyKg;
  static const double deliveryCharge = 20.0;

  DeliveryApproach deliveryApproach = DeliveryApproach.deliverRightAway;
  PaymentMethod paymentMethod = PaymentMethod.gcash;

  static const primaryGreen = GreenTheme.primary;
  static const chipGreen = Color(0xFF4F7652);

  @override
  void initState() {
    super.initState();
    if (widget.currentDemandKg <= 0) {
      qtyKg = 0;
    } else if (widget.currentDemandKg >= 2) {
      qtyKg = 2;
    } else {
      qtyKg = 1;
    }
  }

  bool get noDemand => widget.currentDemandKg <= 0;
  bool get canDecrease => qtyKg > 1;
  bool get canIncrease => qtyKg < widget.currentDemandKg;
  bool get canSupply => widget.currentDemandKg > 0 && qtyKg > 0;

  double get subtotal => qtyKg * widget.unitPricePerKg;
  double get total => subtotal + (canSupply ? deliveryCharge : 0.0);

  void _onSupply() {
    final bool isConfirmed = qtyKg >= 2;

    if (isConfirmed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (pageCtx) => SupplyConfirmationPage(
            produceName: widget.produceName,
            stallName: widget.stallName,
            demandKg: widget.currentDemandKg,
            arrivalText: 'Dec 25, 2025 on Wed at 6:00 pm',
            pickupLocation:
                'Barangay Fort Bonifacio (BGC),\nTaguig City, Metro Manila',
            noteTitle: 'Note:',
            noteBody:
                'Collect payment in cash: ₱${total.toStringAsFixed(2)}\nPlease be there on time!',
            buttonText: 'Back To Home',
            onButtonTap: () {
              Navigator.of(pageCtx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const FarmerHomePage()),
                (route) => false,
              );
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (pageCtx) => SupplyRejectedPage(
            produceName: widget.produceName,
            stallName: widget.stallName,
            demandKg: widget.currentDemandKg,
            noteTitle: 'Note:',
            noteBody:
                'Your supply request was rejected.\nPlease try again with a different quantity or delivery option.',
            onTryAgain: () {
              Navigator.of(pageCtx).pop();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      appBar: AppBar(
        backgroundColor: GreenTheme.softBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.produceName,
                        style: const TextStyle(
                          fontSize: 32,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.stallName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Demand + qty card
            _Card(
              child: Row(
                children: [
                  // image circle
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.06 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: Image.asset(
                          widget.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Current Demand\nFor Delivery',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: chipGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.currentDemandKg}kg',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (noDemand) ...[
                          const SizedBox(height: 8),
                          Text(
                            'No demand available for this stall.',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _CircleBtn(
                              icon: Icons.remove,
                              onTap: noDemand
                                  ? null
                                  : (canDecrease
                                        ? () => setState(() => qtyKg--)
                                        : null),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$qtyKg kg',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: chipGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _CircleBtn(
                              icon: Icons.add,
                              onTap: noDemand
                                  ? null
                                  : (canIncrease
                                        ? () => setState(() => qtyKg++)
                                        : null),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Order summary
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(label: 'Quantity', value: '$qtyKg kg'),
                  _SummaryRow(
                    label: 'Unit Price',
                    value: '₱${widget.unitPricePerKg.toStringAsFixed(0)}/kg',
                  ),
                  _SummaryRow(
                    label: 'Subtotal',
                    value: '₱${subtotal.toStringAsFixed(2)}',
                  ),
                  _SummaryRow(
                    label: 'Delivery Charges',
                    value: canSupply
                        ? '₱${deliveryCharge.toStringAsFixed(2)}'
                        : '₱0.00',
                  ),
                  const Divider(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '₱${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Approach (✅ NEW: RadioGroup)
            const Text(
              'Delivery Approach',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            RadioGroup<DeliveryApproach>(
              groupValue: deliveryApproach,
              onChanged: (v) {
                if (v == null) return;
                setState(() => deliveryApproach = v);
              },
              child: Column(
                children: const [
                  _RadioRow<DeliveryApproach>(
                    label: 'Deliver right away',
                    value: DeliveryApproach.deliverRightAway,
                  ),
                  _RadioRow<DeliveryApproach>(
                    label: 'Help Delivery',
                    value: DeliveryApproach.helpDelivery,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Payment (✅ NEW: RadioGroup)
            const Text(
              'Choose payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            RadioGroup<PaymentMethod>(
              groupValue: paymentMethod,
              onChanged: (v) {
                if (v == null) return;
                setState(() => paymentMethod = v);
              },
              child: Column(
                children: const [
                  _RadioRow<PaymentMethod>(
                    leading: Text('💳', style: TextStyle(fontSize: 18)),
                    label: 'Gcash',
                    value: PaymentMethod.gcash,
                  ),
                  _RadioRow<PaymentMethod>(
                    leading: Text('🪙', style: TextStyle(fontSize: 18)),
                    label: 'Cash',
                    value: PaymentMethod.cash,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Supply button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: canSupply ? _onSupply : null,
                child: Text(
                  canSupply ? 'Supply' : 'No demand',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

/* ----------------- small UI helpers ----------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled ? Colors.grey.shade200 : const Color(0xFF4F7652),
        ),
        child: Icon(icon, color: disabled ? Colors.grey : Colors.white),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Compact tappable radio row that works with Flutter 3.35 RadioGroup API.
class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({this.leading, required this.label, required this.value});

  final Widget? leading;
  final String label;
  final T value;

  @override
  Widget build(BuildContext context) {
    final registry = RadioGroup.maybeOf<T>(context);

    return InkWell(
      onTap: () => registry?.onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            SizedBox(
              width: 26,
              height: 26,
              child: Transform.scale(
                scale: 0.95,
                child: Radio<T>(
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
