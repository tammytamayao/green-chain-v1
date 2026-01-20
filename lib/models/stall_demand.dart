class StallDemand {
  const StallDemand({
    required this.stallName,
    required this.kg,
    required this.productId,
    required this.demandId,
    required this.stallLocation,
  });

  final String stallName;
  final int kg;
  final int productId;
  final int demandId;
  final String stallLocation;
}
