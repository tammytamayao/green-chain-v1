// lib/features/consumer/widgets/consumer_qty_card.dart
import 'package:flutter/material.dart';

import '../../widgets/qty_card_base.dart';
import '../../utils/farmer/cart_constants.dart';

class ConsumerQtyCard extends StatelessWidget {
  const ConsumerQtyCard({
    super.key,
    this.assetPath,
    required this.qtyKg,
    required this.maxStocksKg,
    required this.unitPricePerKg,
    required this.onDec,
    required this.onInc,
  });

  final String? assetPath;
  final int qtyKg;
  final double maxStocksKg;
  final double unitPricePerKg;
  final VoidCallback? onDec;
  final VoidCallback? onInc;

  bool get noStock => maxStocksKg <= 0;

  @override
  Widget build(BuildContext context) {
    return QtyCardBase(
      assetPath: assetPath,
      title: 'Order Quantity',
      chipText: '₱${unitPricePerKg.toStringAsFixed(2)}/kg',
      chipColor: CartConstants.chipGreen,
      infoText: noStock
          ? 'No stocks available for this stall.'
          : 'Available: ${maxStocksKg.toStringAsFixed(1)} kg',
      infoTextColor: noStock ? Colors.red.shade700 : Colors.grey.shade700,
      qtyText: '$qtyKg kg',
      qtyColor: CartConstants.chipGreen,
      onDec: onDec,
      onInc: onInc,
    );
  }
}
