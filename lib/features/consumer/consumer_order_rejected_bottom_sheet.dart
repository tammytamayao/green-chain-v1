// lib/features/consumer/consumer_order_rejected_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:green_chain_v1/features/farmer/utils/cart_constants.dart';

Future<void> showOrderRejectedBottomSheet({
  required BuildContext context,
  required String productName,
  required String stallName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (sheetCtx) {
      final softBg = CartConstants.primaryGreen.withAlpha((0.04 * 255).round());

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: _Content(productName: productName, stallName: stallName),
            ),
          ),
        ),
      );
    },
  );
}

class _Content extends StatelessWidget {
  const _Content({required this.productName, required this.stallName});

  final String productName;
  final String stallName;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.10 * 255).round()),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _StatusBannerLarge(
          icon: Icons.cancel_outlined,
          title: 'Order Rejected',
          background: const Color(0xFFF3DADA),
          border: Colors.redAccent.withAlpha((0.35 * 255).round()),
          textColor: Colors.redAccent,
        ),
        const SizedBox(height: 14),
        _AppCard(
          child: _NoteBlock(
            title: 'Note:',
            body:
                'Your order for $productName from $stallName could not be placed. '
                'Please try again or choose a different stall.',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CartConstants.primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------- Local UI helpers (similar to farmer side) ---------- */

class _StatusBannerLarge extends StatelessWidget {
  const _StatusBannerLarge({
    required this.icon,
    required this.title,
    required this.background,
    required this.border,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color background;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 44),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.redAccent.withAlpha((0.06 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.redAccent.withAlpha((0.18 * 255).round()),
            ),
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
