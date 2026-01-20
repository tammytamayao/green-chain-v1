import 'package:flutter/foundation.dart';

import '../../../utils/farmer/cart_constants.dart';

@immutable
class CartState {
  const CartState({
    required this.demandKg,
    required this.qtyKg,
    required this.unitPricePerKg,
  });

  final int demandKg;
  final int qtyKg;
  final double unitPricePerKg;

  bool get noDemand => demandKg <= 0;
  bool get canDecrease => qtyKg > 0;
  bool get canIncrease => qtyKg < demandKg;
  bool get canSupply => demandKg > 0 && qtyKg > 0;

  double get subtotal => qtyKg * unitPricePerKg;
  double get delivery => canSupply ? CartConstants.deliveryCharge : 0.0;
  double get total => subtotal + delivery;

  int clampQty(int next) {
    if (demandKg <= 0) return 0;
    if (next < 0) return 0;
    if (next > demandKg) return demandKg;
    return next;
  }
}
