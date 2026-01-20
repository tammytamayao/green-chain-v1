// lib/screens/farmer/supply/farmer_supply_helpers.dart

import '../../../widgets/farmers/payment_card.dart';

/// Convert PaymentMethod enum to the API string expected by the backend.
String paymentMethodToApi(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.gcash:
      return 'gcash';
    case PaymentMethod.cash:
      return 'cash';
  }
}
