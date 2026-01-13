// lib/widgets/current_price_header.dart
import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/utils/date_utils.dart';

class CurrentPriceHeader extends StatelessWidget {
  const CurrentPriceHeader({super.key});

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Price',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              niceNow(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
