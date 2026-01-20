import 'package:green_chain_v1/models/stall_demand.dart';

class ProductDemand {
  const ProductDemand({
    required this.title,
    required this.asset,
    required this.pricePerKg,
    required this.stalls,
  });

  final String title;
  final String asset;
  final double pricePerKg;
  final List<StallDemand> stalls;
}
