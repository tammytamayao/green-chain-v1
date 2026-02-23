// widget/buy_tab_sliver.dart (modified)
// Changes:
// - status derivation simplified (your demands cache is OPEN-only)
// - "Completed" won't appear here because GET /demands returns only open

import 'package:flutter/material.dart';
import '../disposer_orders_model.dart';
import 'buy_card.dart';
import 'package:green_chain_v1/models/demand.dart';

class BuyTabSliver extends StatelessWidget {
  const BuyTabSliver({
    super.key,
    required this.items,
    required this.buyRequests,
    required this.onSaveRequest,
    this.onDeleteRequest,
    required this.processingByProductId,
    this.onProcessRequest,
    required this.demandsByProductId,
  });

  final List<MarketItem> items;
  final Map<int, double> buyRequests;
  final Map<int, bool> processingByProductId;
  final void Function(MarketItem item, double value) onSaveRequest;
  final void Function(MarketItem item)? onDeleteRequest;

  final void Function(MarketItem item)? onProcessRequest;

  /// OPEN-only demand map used to derive "Processing" label
  final Map<int, Demand> demandsByProductId;

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

          final demand = demandsByProductId[item.productId];
          final String? status = (demand != null && demand.requestsCount > 0)
              ? 'Processing'
              : null;

          return BuyCard(
            item: item,
            initialRequest: requested,
            hasRequest: hasRequest,
            isProcessing: isProcessing,
            status: status,
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
