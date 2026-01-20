import 'package:flutter/material.dart';

import '../../../utils/farmer/cart_constants.dart';
import '../../../widgets/farmers/ui_helpers.dart';

Future<void> showRejectedBottomSheet({
  required BuildContext context,
  required String produceName,
  required String stallName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white, // 👈 standard sheet background
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
              color: softBg, // 👈 consistent soft background
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: _content(sheetCtx, produceName, stallName),
            ),
          ),
        ),
      );
    },
  );
}

Widget _content(BuildContext ctx, String produceName, String stallName) {
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
      StatusBannerLarge(
        icon: Icons.cancel_outlined,
        title: 'Rejected',
        background: const Color(0xFFF3DADA),
        border: Colors.redAccent.withAlpha((0.35 * 255).round()),
        textColor: Colors.redAccent,
      ),
      const SizedBox(height: 14),
      AppCard(
        child: NoteBlock(
          title: 'Note:',
          body:
              'Your $produceName supply request for $stallName was rejected. '
              'Please try again.',
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
            'Back to Cart',
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
