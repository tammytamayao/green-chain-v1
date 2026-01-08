import 'package:flutter/material.dart';
import '../../../ui/green_theme.dart';

class OrdersHeaderSliver extends StatelessWidget {
  const OrdersHeaderSliver({super.key, required this.dateText});

  final String dateText;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: GreenTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateText,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
