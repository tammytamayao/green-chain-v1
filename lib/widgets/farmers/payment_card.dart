import 'package:flutter/material.dart';
import 'ui_helpers.dart';

enum PaymentMethod { gcash, cash }

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.value, required this.onChanged});

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose payment method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          RadioGroup<PaymentMethod>(
            groupValue: value,
            onChanged: (v) {
              if (v == null) return;
              onChanged(v);
            },
            child: Column(
              children: const [
                _RadioRow<PaymentMethod>(
                  leading: Text('💳', style: TextStyle(fontSize: 16)),
                  label: 'Gcash',
                  value: PaymentMethod.gcash,
                ),
                _RadioRow<PaymentMethod>(
                  leading: Text('🪙', style: TextStyle(fontSize: 16)),
                  label: 'Cash',
                  value: PaymentMethod.cash,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
