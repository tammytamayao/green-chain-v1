// lib/features/cart/widgets/demand_qty_card.dart
import 'package:flutter/material.dart';

import '../../../widgets/qty_card_base.dart';
import '../utils/cart_constants.dart';

class DemandQtyCard extends StatelessWidget {
  const DemandQtyCard({
    super.key,
    required this.assetPath,
    required this.demandKg,
    required this.qtyKg,
    required this.onDec,
    required this.onInc,
  });

  final String assetPath;
  final int demandKg;
  final int qtyKg;
  final VoidCallback? onDec;
  final VoidCallback? onInc;

  bool get noDemand => demandKg <= 0;

  @override
  Widget build(BuildContext context) {
    return QtyCardBase(
      assetPath: assetPath,
      title: 'Current Demand\nFor Delivery',
      chipText: '${demandKg}kg',
      chipColor: CartConstants.chipGreen,
      infoText: noDemand ? 'No demand available for this stall.' : null,
      infoTextColor: noDemand ? Colors.red.shade700 : null,
      qtyText: '$qtyKg kg',
      qtyColor: CartConstants.chipGreen,
      onDec: onDec,
      onInc: onInc,
    );
  }
}
