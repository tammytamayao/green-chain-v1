import 'package:green_chain_v1/models/order.dart';
import 'package:green_chain_v1/models/delivery.dart';

class OrderCreateResponse {
  final ConsumerOrder order;
  final Delivery delivery;

  OrderCreateResponse({required this.order, required this.delivery});

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      order: ConsumerOrder.fromJson(json['order'] as Map<String, dynamic>),
      delivery: Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
    );
  }
}
