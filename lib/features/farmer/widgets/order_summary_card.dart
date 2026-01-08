import 'package:flutter/material.dart';
import '../utils/cart_constants.dart';
import 'ui_helpers.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.qtyKg,
    required this.unitPricePerKg,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  final int qtyKg;
  final double unitPricePerKg;
  final double subtotal;
  final double delivery;
  final double total;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SummaryRow(label: 'Quantity', value: '$qtyKg kg'),
          SummaryRow(
            label: 'Unit Price',
            value: '₱${unitPricePerKg.toStringAsFixed(0)}/kg',
          ),
          SummaryRow(
            label: 'Subtotal',
            value: '₱${subtotal.toStringAsFixed(2)}',
          ),
          SummaryRow(
            label: 'Delivery Charges',
            value: '₱${delivery.toStringAsFixed(2)}',
          ),
          const Divider(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: CartConstants.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
