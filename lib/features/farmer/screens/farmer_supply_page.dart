import 'package:flutter/material.dart';

import '../../../home_farmer.dart';
import '../../../supply_confirmation_page.dart';
import '../../../ui/green_theme.dart';
import '../modals/rejected_bottom_sheet.dart';
import '../models/cart_state.dart';
import '../utils/cart_constants.dart';
import '../utils/date_helpers.dart';
import '../widgets/delivery_approach_card.dart';
import '../widgets/demand_qty_card.dart';
import '../widgets/header.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_card.dart';
import '../widgets/supply_button.dart';

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

  DeliveryApproach deliveryApproach = DeliveryApproach.deliverRightAway;
  PaymentMethod paymentMethod = PaymentMethod.gcash;

  @override
  void initState() {
    super.initState();
    qtyKg = widget.currentDemandKg > 0 ? 1 : 0;
  }

  CartState get cart => CartState(
    demandKg: widget.currentDemandKg,
    qtyKg: qtyKg,
    unitPricePerKg: widget.unitPricePerKg,
  );

  String _noteBodyByPayment(double total) {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Collect payment in cash: ₱${total.toStringAsFixed(2)}\n'
            'Please be there on time!';
      case PaymentMethod.gcash:
        return 'Payment via GCash: ₱${total.toStringAsFixed(2)}\n'
            'Please confirm once delivered.';
    }
  }

  Future<void> _onSupply() async {
    if (!mounted) return;

    final isConfirmed = cart.qtyKg >= 1; // your demo rule

    if (!isConfirmed) {
      await showRejectedBottomSheet(
        context: context,
        produceName: widget.produceName,
        stallName: widget.stallName,
      );
      return;
    }

    final arrivalText = arrivalTextPlus3Days();
    final noteBody = _noteBodyByPayment(cart.total);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (pageCtx) => SupplyConfirmationPage(
          produceName: widget.produceName,
          stallName: widget.stallName,
          demandKg: widget.currentDemandKg,
          suppliedKg: cart.qtyKg,
          arrivalText: arrivalText,
          pickupLocation: CartConstants.farmerLocation,
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
  }

  @override
  Widget build(BuildContext context) {
    final state = cart;

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
            CartHeader(
              produceName: widget.produceName,
              stallName: widget.stallName,
            ),
            const SizedBox(height: 14),

            DemandQtyCard(
              assetPath: widget.assetPath,
              demandKg: widget.currentDemandKg,
              qtyKg: qtyKg,
              onDec: state.noDemand
                  ? null
                  : (state.canDecrease
                        ? () =>
                              setState(() => qtyKg = state.clampQty(qtyKg - 1))
                        : null),
              onInc: state.noDemand
                  ? null
                  : (state.canIncrease
                        ? () =>
                              setState(() => qtyKg = state.clampQty(qtyKg + 1))
                        : null),
            ),
            const SizedBox(height: 14),

            OrderSummaryCard(
              qtyKg: state.qtyKg,
              unitPricePerKg: widget.unitPricePerKg,
              subtotal: state.subtotal,
              delivery: state.delivery,
              total: state.total,
            ),
            const SizedBox(height: 16),

            DeliveryApproachCard(
              value: deliveryApproach,
              onChanged: (v) => setState(() => deliveryApproach = v),
            ),
            const SizedBox(height: 14),

            PaymentCard(
              value: paymentMethod,
              onChanged: (v) => setState(() => paymentMethod = v),
            ),
            const SizedBox(height: 18),

            SupplyButton(enabled: state.canSupply, onPressed: _onSupply),
          ],
        ),
      ),
    );
  }
}
