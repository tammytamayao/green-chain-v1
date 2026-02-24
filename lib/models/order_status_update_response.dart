import 'package:green_chain_v1/models/order.dart';
import 'package:green_chain_v1/models/delivery.dart';

class OrderStatusUpdateResponse {
  final ConsumerOrder order;
  final Delivery? delivery;

  OrderStatusUpdateResponse({required this.order, this.delivery});

  factory OrderStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateResponse(
      order: ConsumerOrder.fromJson(json['order'] as Map<String, dynamic>),
      delivery: json['delivery'] == null
          ? null
          : Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
    );
  }
}
