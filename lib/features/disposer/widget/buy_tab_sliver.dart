import 'package:flutter/material.dart';

import '../disposer_orders_model.dart';
import 'buy_card.dart';

class BuyTabSliver extends StatelessWidget {
  const BuyTabSliver({
    super.key,
    required this.items,
    required this.buyRequests,
    required this.onSaveRequest,
  });

  final List<MarketItem> items;
  final Map<String, double> buyRequests;
  final void Function(String name, double value) onSaveRequest;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          final requested = buyRequests[item.name];

          return BuyCard(
            item: item,
            initialRequest: requested,
            onSave: (double value) => onSaveRequest(item.name, value),
          );
        },
      ),
    );
  }
}
