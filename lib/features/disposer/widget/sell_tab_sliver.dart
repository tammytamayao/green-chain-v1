import 'package:flutter/material.dart';
import '../disposer_orders_model.dart';
import 'sell_card.dart';

class SellTabSliver extends StatelessWidget {
  const SellTabSliver({
    super.key,
    required this.items,
    required this.onUpdateVariantPrice,
  });

  final List<SellLot> items;
  final void Function(SellLot lot, VariantPrice variant, double newPrice)
  onUpdateVariantPrice;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lot = items[index];
          return SellCard(
            lot: lot,
            onUpdateVariantPrice: (variant, newPrice) {
              onUpdateVariantPrice(lot, variant, newPrice);
            },
          );
        },
      ),
    );
  }
}
