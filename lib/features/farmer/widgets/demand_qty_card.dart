import 'package:flutter/material.dart';
import '../utils/cart_constants.dart';
import 'ui_helpers.dart';

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
    return CardShell(
      child: Row(
        children: [
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
                  assetPath,
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
                        color: CartConstants.chipGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${demandKg}kg',
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
                    CircleBtn(icon: Icons.remove, onTap: onDec),
                    const SizedBox(width: 12),
                    Text(
                      '$qtyKg kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: CartConstants.chipGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleBtn(icon: Icons.add, onTap: onInc),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
