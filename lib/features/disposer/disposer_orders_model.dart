import 'package:flutter/foundation.dart';

@immutable
class MarketItem {
  final String name;
  final double price;
  final String unit;
  final String assetPath;
  final int available;

  const MarketItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.assetPath,
    required this.available,
  });
}

@immutable
class SellLot {
  final String name;
  final double price;
  final String unit;
  final String assetPath;
  final int quantity;
  final String status;

  const SellLot({
    required this.name,
    required this.price,
    required this.unit,
    required this.assetPath,
    required this.quantity,
    required this.status,
  });
}
