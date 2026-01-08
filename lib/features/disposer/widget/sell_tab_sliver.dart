import 'package:flutter/material.dart';

import '../disposer_orders_model.dart';
import 'sell_card.dart';

class SellTabSliver extends StatelessWidget {
  const SellTabSliver({super.key, required this.items});

  final List<SellLot> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final lot = items[i];
          return SellCard(lot: lot);
        },
      ),
    );
  }
}
