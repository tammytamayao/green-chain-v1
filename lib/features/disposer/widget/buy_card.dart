import 'package:flutter/material.dart';
import '../../../ui/green_theme.dart';
import '../disposer_orders_model.dart';

class BuyCard extends StatelessWidget {
  const BuyCard({
    super.key,
    required this.item,
    required this.initialRequest,
    required this.hasRequest,
    required this.onSave,
    this.onDelete,
  });

  final MarketItem item;
  final double? initialRequest;
  final bool hasRequest;
  final ValueChanged<double> onSave;
  final VoidCallback? onDelete;

  void _openRequestDialog(BuildContext context) {
    final controller = TextEditingController(
      text: initialRequest == null ? '' : initialRequest.toString(),
    );
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSB) {
            void handleSave() {
              final text = controller.text.trim();
              if (text.isEmpty) {
                setStateSB(() => errorText = 'Please enter amount in kg');
                return;
              }
              final value = double.tryParse(text);
              if (value == null || value <= 0) {
                setStateSB(() => errorText = 'Enter a valid positive number');
                return;
              }
              onSave(value);
              Navigator.of(ctx).pop();
            }

            return AlertDialog(
              backgroundColor: GreenTheme.softBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lettuce type as title
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GreenTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Price | Current stock
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₱${item.price.toStringAsFixed(2)} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current stock',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.available} kg',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Request field
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Request (kg)',
                      hintText: 'Enter kilograms',
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    final requestedDisplay =
        (!hasRequest || initialRequest == null || initialRequest! <= 0)
        ? 'None yet'
        : '${initialRequest!.toStringAsFixed(2)} kg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: big thumbnail
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/romaine.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 18),

          // RIGHT: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${item.price.toStringAsFixed(2)} ${item.unit}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GreenTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Current stock: ${item.available} kg',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested: $requestedDisplay',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: hasRequest
                      ? OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text(
                            'Delete request',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _openRequestDialog(context),
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Request',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GreenTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1.5,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
