import 'package:flutter/foundation.dart';

@immutable
class MarketItem {
  final int productId;
  final String name;
  final double price;
  final String unit;
  final String assetPath;
  final int available;

  const MarketItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.assetPath,
    required this.available,
  });
}

enum LettuceSize { small, big }

extension LettuceSizeLabel on LettuceSize {
  String get label {
    switch (this) {
      case LettuceSize.small:
        return 'Small';
      case LettuceSize.big:
        return 'Big';
    }
  }
}

enum LettuceVariantType { organic, nonOrganic }

extension LettuceVariantTypeLabel on LettuceVariantType {
  String get label {
    switch (this) {
      case LettuceVariantType.organic:
        return 'Organic';
      case LettuceVariantType.nonOrganic:
        return 'Non-organic';
    }
  }
}

@immutable
class VariantPrice {
  final int id;
  final LettuceSize size;
  final LettuceVariantType variantType;
  final double price;
  final double stockKg;

  const VariantPrice({
    required this.id,
    required this.size,
    required this.variantType,
    required this.price,
    required this.stockKg,
  });

  VariantPrice copyWith({double? price, double? stockKg}) {
    return VariantPrice(
      id: id,
      size: size,
      variantType: variantType,
      price: price ?? this.price,
      stockKg: stockKg ?? this.stockKg,
    );
  }
}

@immutable
class SellLot {
  final String name;
  final String unit;
  final String assetPath;
  final String status;
  final List<VariantPrice> variants;

  const SellLot({
    required this.name,
    required this.unit,
    required this.assetPath,
    required this.status,
    required this.variants,
  });

  double get totalStockKg => variants.fold(0.0, (sum, v) => sum + v.stockKg);

  double get minPrice => variants.isEmpty
      ? 0
      : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);

  double get maxPrice => variants.isEmpty
      ? 0
      : variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);

  SellLot copyWith({String? status, List<VariantPrice>? variants}) {
    return SellLot(
      name: name,
      unit: unit,
      assetPath: assetPath,
      status: status ?? this.status,
      variants: variants ?? this.variants,
    );
  }
}
