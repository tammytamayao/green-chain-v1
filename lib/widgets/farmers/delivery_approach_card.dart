import 'package:flutter/material.dart';
import 'ui_helpers.dart';

enum DeliveryApproach { deliverRightAway, helpDelivery }

class DeliveryApproachCard extends StatelessWidget {
  const DeliveryApproachCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DeliveryApproach value;
  final ValueChanged<DeliveryApproach> onChanged;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Approach',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          RadioGroup<DeliveryApproach>(
            groupValue: value,
            onChanged: (v) {
              if (v == null) return;
              onChanged(v);
            },
            child: Column(
              children: const [
                _RadioRow<DeliveryApproach>(
                  label: 'Deliver right away',
                  value: DeliveryApproach.deliverRightAway,
                ),
                _RadioRow<DeliveryApproach>(
                  label: 'Help Delivery',
                  value: DeliveryApproach.helpDelivery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep this local if only used here.
class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({this.leading, required this.label, required this.value});

  final Widget? leading;
  final String label;
  final T value;

  @override
  Widget build(BuildContext context) {
    final registry = RadioGroup.maybeOf<T>(context);

    return InkWell(
      onTap: () => registry?.onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            SizedBox(
              width: 26,
              height: 26,
              child: Transform.scale(
                scale: 0.95,
                child: Radio<T>(
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
