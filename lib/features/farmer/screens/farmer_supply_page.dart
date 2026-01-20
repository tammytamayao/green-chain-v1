import 'package:flutter/material.dart';
import 'package:green_chain_v1/utils/farmer/build_payment_note.dart';
import 'package:green_chain_v1/utils/farmer/date_helpers.dart';
import 'package:green_chain_v1/utils/farmer/payment_method_to_api.dart';

import 'farmer_supply_confirmation_page.dart';
import '../../../ui/green_theme.dart';
import '../modals/rejected_bottom_sheet.dart';
import '../models/cart_state.dart';
import '../../../widgets/farmers/delivery_approach_card.dart';
import '../../../widgets/farmers/demand_qty_card.dart';
import '../../../widgets/farmers/header.dart';
import '../../../widgets/farmers/order_summary_card.dart';
import '../../../widgets/farmers/payment_card.dart';
import '../../../widgets/farmers/supply_button.dart';
import 'farmer_home_page.dart';

// API
import '../../../api/supply_api.dart';

class FarmerSupplyPage extends StatefulWidget {
  const FarmerSupplyPage({
    super.key,
    required this.produceName,
    required this.stallName,
    required this.stallLocation,
    required this.currentDemandKg,
    required this.unitPricePerKg,
    required this.assetPath,
    required this.productId,
    required this.demandId,
    required this.farmerLocation,
  });

  final String produceName;
  final String stallName;
  final String stallLocation;
  final int currentDemandKg;
  final double unitPricePerKg;
  final String assetPath;
  final int productId;
  final int demandId;
  final String farmerLocation;

  @override
  State<FarmerSupplyPage> createState() => _FarmerSupplyPageState();
}

class _FarmerSupplyPageState extends State<FarmerSupplyPage> {
  late int qtyKg;

  DeliveryApproach deliveryApproach = DeliveryApproach.deliverRightAway;
  PaymentMethod paymentMethod = PaymentMethod.gcash;

  bool _isSubmitting = false;

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

  Future<void> _showRejected() async {
    await showRejectedBottomSheet(
      context: context,
      produceName: widget.produceName,
      stallName: widget.stallName,
    );
  }

  Future<void> _onSupply() async {
    if (!mounted || _isSubmitting) return;

    // Front-end rule: at least 1kg
    if (cart.qtyKg < 1) {
      await _showRejected();
      return;
    }

    final methodStr = paymentMethodToApi(paymentMethod);

    setState(() {
      _isSubmitting = true;
    });

    try {
      await createSupplyAndRequest(
        productId: widget.productId,
        weight: cart.qtyKg.toDouble(),
        demandId: widget.demandId,
        price: cart.total,
        method: methodStr,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Backend failed (validation, mismatch, etc.)
      await _showRejected();
      return;
    }

    final arrivalText = arrivalTextPlus3Days();
    final noteBody = buildPaymentNote(paymentMethod, cart.total);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (pageCtx) => SupplyConfirmationPage(
          produceName: widget.produceName,
          stallName: widget.stallName,
          demandKg: widget.currentDemandKg,
          suppliedKg: cart.qtyKg,
          arrivalText: arrivalText,
          pickupLocation: widget.farmerLocation, // real farmer location
          deliveryLocation: widget.stallLocation, // real stall location
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

            SupplyButton(
              enabled: !_isSubmitting && state.canSupply,
              onPressed: _onSupply,
            ),
          ],
        ),
      ),
    );
  }
}
