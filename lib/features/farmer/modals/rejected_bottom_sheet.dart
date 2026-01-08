import 'package:flutter/material.dart';

import '../utils/cart_constants.dart';
import '../widgets/ui_helpers.dart';

Future<void> showRejectedBottomSheet({
  required BuildContext context,
  required String produceName,
  required String stallName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha((0.35 * 255).round()),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: CartConstants.primaryGreen.withAlpha((0.04 * 255).round()),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.10 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
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
                      onPressed: () => Navigator.pop(sheetCtx),
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
              ),
            ),
          ),
        ),
      );
    },
  );
}
