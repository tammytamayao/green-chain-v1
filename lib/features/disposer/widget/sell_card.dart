import 'package:flutter/material.dart';
import '../../../ui/green_theme.dart';
import '../disposer_orders_model.dart';

class SellCard extends StatelessWidget {
  const SellCard({
    super.key,
    required this.lot,
    required this.onUpdateVariantPrice,
  });

  final SellLot lot;
  final void Function(VariantPrice variant, double newPrice)
  onUpdateVariantPrice;

  List<VariantPrice> _buildAllVariants() {
    final List<VariantPrice> all = [];
    for (final size in LettuceSize.values) {
      for (final type in LettuceVariantType.values) {
        final existing = lot.variants.where(
          (v) => v.size == size && v.variantType == type,
        );
        if (existing.isNotEmpty) {
          all.add(existing.first);
        } else {
          all.add(
            VariantPrice(
              id: -1,
              size: size,
              variantType: type,
              price: 0.0,
              stockKg: 0.0,
            ),
          );
        }
      }
    }
    return all;
  }

  void _openEditPriceDialog(BuildContext context, VariantPrice variant) {
    final controller = TextEditingController(
      text: variant.price.toStringAsFixed(2),
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
                setStateSB(() => errorText = 'Please enter a price');
                return;
              }
              final value = double.tryParse(text);
              if (value == null || value <= 0) {
                setStateSB(() => errorText = 'Enter a valid positive number');
                return;
              }
              onUpdateVariantPrice(variant, value);
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
                  Text(
                    lot.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: GreenTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${variant.size.label} • ${variant.variantType.label}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock: ${variant.stockKg.toStringAsFixed(1)} kg',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price (${lot.unit})',
                      hintText: 'Enter price per kg',
                      prefixText: '₱',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: errorText,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
    final radius = BorderRadius.circular(18);
    final allVariants = _buildAllVariants();

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    lot.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/romaine.jpg', fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total stock: ${lot.totalStockKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (lot.variants.isNotEmpty)
                      Text(
                        'Price range: ₱${lot.minPrice.toStringAsFixed(2)} - ₱${lot.maxPrice.toStringAsFixed(2)} ${lot.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 10;
              final double tileWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: allVariants.map((variant) {
                  return SizedBox(
                    width: tileWidth,
                    child: _VariantTile(
                      lot: lot,
                      variant: variant,
                      onTap: () => _openEditPriceDialog(context, variant),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.lot,
    required this.variant,
    required this.onTap,
  });

  final SellLot lot;
  final VariantPrice variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: GreenTheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${variant.size.label} • ${variant.variantType.label}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '₱${variant.price.toStringAsFixed(2)} ${lot.unit}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: GreenTheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${variant.stockKg.toStringAsFixed(1)} kg',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
