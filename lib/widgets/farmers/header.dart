import 'package:flutter/material.dart';

import '../../utils/farmer/cart_constants.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({
    super.key,
    required this.produceName,
    required this.stallName,
  });

  final String produceName;
  final String stallName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produceName,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: CartConstants.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stallName,
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
    );
  }
}
