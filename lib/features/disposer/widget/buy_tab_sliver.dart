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
    required this.processingByProductId,
    this.onProcessRequest,
  });

  final List<MarketItem> items;
  final Map<int, double> buyRequests;
  final Map<int, bool> processingByProductId;
  final void Function(MarketItem item, double value) onSaveRequest;
  final void Function(MarketItem item)? onDeleteRequest;

  /// Called when disposer taps "Process" on a request card.
  /// The page will show the allocation dialog + update inventory.
  final void Function(MarketItem item)? onProcessRequest;

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
          final isProcessing = processingByProductId[item.productId] ?? false;

          return BuyCard(
            item: item,
            initialRequest: requested,
            hasRequest: hasRequest,
            isProcessing: isProcessing,
            onSave: (double value) => onSaveRequest(item, value),
            onDelete: onDeleteRequest == null
                ? null
                : () => onDeleteRequest!(item),
            onProcess: onProcessRequest == null
                ? null
                : () => onProcessRequest!(item),
          );
        },
      ),
    );
  }
}
