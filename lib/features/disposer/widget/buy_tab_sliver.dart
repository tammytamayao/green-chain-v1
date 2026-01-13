import 'package:flutter/material.dart';

import '../disposer_orders_model.dart';
import 'buy_card.dart';

class BuyTabSliver extends StatelessWidget {
  const BuyTabSliver({
    super.key,
    required this.items,
    required this.buyRequests,
    required this.onSaveRequest,
    this.onDeleteRequest,
    required this.processingByProductId, // NEW
  });

  final List<MarketItem> items;

  /// Map of productId -> requested weight (kg)
  final Map<int, double> buyRequests;

  /// Map of productId -> whether there is already a request (supply) for its demand
  final Map<int, bool> processingByProductId; // NEW

  final void Function(MarketItem item, double value) onSaveRequest;
  final void Function(MarketItem item)? onDeleteRequest;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          final requested = buyRequests[item.productId];
          final hasRequest = requested != null && requested > 0;
          final isProcessing =
              processingByProductId[item.productId] ?? false; // NEW

          return BuyCard(
            item: item,
            initialRequest: requested,
            hasRequest: hasRequest,
            isProcessing: isProcessing, // NEW
            onSave: (double value) => onSaveRequest(item, value),
            onDelete: onDeleteRequest == null
                ? null
                : () => onDeleteRequest!(item),
          );
        },
      ),
    );
  }
}
