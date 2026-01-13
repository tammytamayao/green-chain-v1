import 'package:green_chain_v1/models/product.dart';

String assetForProduct(Product p) {
  final slug = p.variant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  return 'assets/$slug.jpg';
}
