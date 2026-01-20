// farmer_demand_section.dart

import 'package:flutter/material.dart';
import 'package:green_chain_v1/models/product_demand.dart';
import 'package:green_chain_v1/models/stall_demand.dart';

import '../../../../ui/green_theme.dart';

class DemandSection extends StatelessWidget {
  const DemandSection({
    super.key,
    required this.data,
    required this.onTapStall,
  });

  final ProductDemand data;
  final void Function(StallDemand stall) onTapStall;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = GreenTheme.primary;
    const chipBg = Color(0xFF4F7652);

    const titleStyle = TextStyle(
      color: primaryGreen,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: 0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product header (product name)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: primaryGreen.withAlpha((0.25 * 255).round()),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text(data.title, style: titleStyle)),
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stalls + kg list
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  for (final stall in data.stalls)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onTapStall(stall),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.05 * 255).round(),
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${stall.stallName}: ${stall.kg}kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Circular image preview (product picture)
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: primaryGreen.withAlpha((0.25 * 255).round()),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.04 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(
                        data.asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/romaine.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
