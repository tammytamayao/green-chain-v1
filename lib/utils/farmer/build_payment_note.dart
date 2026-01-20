import 'package:green_chain_v1/widgets/farmers/payment_card.dart';

/// Build the note body text shown on the confirmation page,
/// based on payment method + total amount.
String buildPaymentNote(PaymentMethod method, double total) {
  final formatted = total.toStringAsFixed(2);

  switch (method) {
    case PaymentMethod.cash:
      return 'Collect payment in cash: ₱$formatted\n'
          'Please be there on time!';
    case PaymentMethod.gcash:
      return 'Payment via GCash: ₱$formatted\n'
          'Please confirm once delivered.';
  }
}
