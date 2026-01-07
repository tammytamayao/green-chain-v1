import 'package:flutter/material.dart';
import 'ui/green_theme.dart';

import 'home_farmer.dart';
import 'supply_confirmation_page.dart';
// import 'supply_rejected_page.dart'; // ✅ no longer needed

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
  // dynamic init based on demand
  late int qtyKg;

  // adjust if you want dynamic delivery charge
  static const double deliveryCharge = 20.0;

  DeliveryApproach deliveryApproach = DeliveryApproach.deliverRightAway;
  PaymentMethod paymentMethod = PaymentMethod.gcash;

  static const primaryGreen = GreenTheme.primary;
  static const chipGreen = Color(0xFF4F7652);

  // Placeholder farm location (replace with backend/profile later)
  static const String _farmerLocation =
      'Barangay Fort Bonifacio (BGC),\nTaguig City, Metro Manila';

  @override
  void initState() {
    super.initState();
    // Start at 2 if possible, else 1 (never exceed demand)
    if (widget.currentDemandKg <= 0) {
      qtyKg = 0;
    } else if (widget.currentDemandKg >= 1) {
      qtyKg = 1;
    } else {
      qtyKg = 1;
    }
  }

  bool get noDemand => widget.currentDemandKg <= 0;
  bool get canDecrease => qtyKg > 0;
  bool get canIncrease => qtyKg < widget.currentDemandKg;
  bool get canSupply => widget.currentDemandKg > 0 && qtyKg > 0;

  double get subtotal => qtyKg * widget.unitPricePerKg;
  double get total => subtotal + (canSupply ? deliveryCharge : 0.0);

  // ---- placeholders (dynamic) ----

  /// ✅ Hot-reload safe: does NOT use context.
  String _arrivalTextPlus3Days() {
    final arrival = DateTime.now().add(const Duration(days: 3));
    const time = '6:00 PM'; // fixed placeholder (no context)

    return '${_monthName(arrival.month)} ${arrival.day}, ${arrival.year} '
        'on ${_weekdayName(arrival.weekday)} at $time';
  }

  String _noteBodyByPayment() {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Collect payment in cash: ₱${total.toStringAsFixed(2)}\n'
            'Please be there on time!';
      case PaymentMethod.gcash:
        return 'Payment via GCash: ₱${total.toStringAsFixed(2)}\n'
            'Please confirm once delivered.';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // ---- rejected modal ----

  void _showRejectedBottomSheet() {
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha((0.35 * 255).round()),
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: GreenTheme.softBg,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.10 * 255).round()),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // grab handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.10 * 255).round()),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _StatusBannerLarge(
                      icon: Icons.cancel_outlined,
                      title: 'Rejected',
                      background: const Color(0xFFF3DADA),
                      border: Colors.redAccent.withAlpha((0.35 * 255).round()),
                      textColor: Colors.redAccent,
                    ),

                    const SizedBox(height: 14),

                    _AppCard(
                      child: _NoteBlock(
                        title: 'Note:',
                        body:
                            'Your ${widget.produceName} supply request for ${widget.stallName} was rejected. '
                            'Please try again.',
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: const Text(
                          'Back to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- supply action ----

  void _onSupply() {
    if (!mounted) return;

    final bool isConfirmed = qtyKg >= 1; // demo rule

    if (isConfirmed) {
      final arrivalText = _arrivalTextPlus3Days();
      final noteBody = _noteBodyByPayment();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (pageCtx) => SupplyConfirmationPage(
            produceName: widget.produceName,
            stallName: widget.stallName,
            demandKg: widget.currentDemandKg,
            suppliedKg: qtyKg,
            arrivalText: arrivalText,
            pickupLocation: _farmerLocation,
            noteTitle: 'Note:',
            noteBody: noteBody,
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
      // ✅ show modal instead of navigating to a page
      _showRejectedBottomSheet();
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

            // Delivery Approach
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Payment
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          leading: Text('💳', style: TextStyle(fontSize: 16)),
                          label: 'Gcash',
                          value: PaymentMethod.gcash,
                        ),
                        _RadioRow<PaymentMethod>(
                          leading: Text('🪙', style: TextStyle(fontSize: 16)),
                          label: 'Cash',
                          value: PaymentMethod.cash,
                        ),
                      ],
                    ),
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

/// Compact tappable radio row for Flutter 3.35 RadioGroup API.
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
        padding: const EdgeInsets.symmetric(vertical: 4),
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

/* ---------------- modal UI pieces (copied from rejected page) ---------------- */

class _AppCard extends StatelessWidget {
  const _AppCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.title, required this.body});
  final String title;
  final String body;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryGreen.withAlpha((0.06 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryGreen.withAlpha((0.18 * 255).round()),
            ),
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBannerLarge extends StatelessWidget {
  const _StatusBannerLarge({
    required this.icon,
    required this.title,
    required this.background,
    required this.border,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color background;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 44),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
