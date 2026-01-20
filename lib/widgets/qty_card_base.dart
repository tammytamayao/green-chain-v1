// lib/features/cart/widgets/qty_card_base.dart
import 'package:flutter/material.dart';

import '../utils/farmer/cart_constants.dart';
import 'farmers/ui_helpers.dart';

class QtyCardBase extends StatelessWidget {
  const QtyCardBase({
    super.key,
    required this.assetPath,
    required this.title,
    required this.chipText,
    this.chipColor,
    this.infoText,
    this.infoTextColor,
    required this.qtyText,
    this.qtyColor,
    this.onDec,
    this.onInc,
  });

  final String? assetPath;
  final String title;
  final String chipText;
  final Color? chipColor;

  /// Optional text under the title (e.g. "Available: 10kg" or "No demand...")
  final String? infoText;
  final Color? infoTextColor;

  /// Middle big quantity label, e.g. "5 kg"
  final String qtyText;
  final Color? qtyColor;

  final VoidCallback? onDec;
  final VoidCallback? onInc;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Row(
        children: [
          // Circular thumbnail (image or fallback icon)
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
                child: assetPath != null
                    ? Image.asset(
                        assetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      )
                    : const Icon(Icons.shopping_basket_outlined, size: 32),
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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
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
                        color: chipColor ?? CartConstants.chipGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chipText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (infoText != null && infoText!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    infoText!,
                    style: TextStyle(
                      color: infoTextColor ?? Colors.grey.shade700,
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
                      qtyText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: qtyColor ?? CartConstants.chipGreen,
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
