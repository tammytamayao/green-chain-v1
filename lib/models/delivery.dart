// lib/models/delivery.dart
class Delivery {
  final int id;
  final String origin;
  final String destination;

  final int? driverId;
  final int? vehicleId;

  final int? orderId;
  final int? requestId;

  /// unassigned/assigned/picked_up/in_transit/delivered/cancelled
  final String status;

  final int createdAt;
  final int? assignedAt;
  final int? pickedUpAt;
  final int? deliveredAt;

  /// ✅ NEW (from backend joined payload)
  /// "order" | "request"
  final String? kind;

  /// ✅ NEW (from orders.weight OR supplies.weight)
  final double? weight;

  /// ✅ NEW (from orders.amount OR requests.price)
  final double? price;

  const Delivery({
    required this.id,
    required this.origin,
    required this.destination,
    required this.driverId,
    required this.vehicleId,
    required this.orderId,
    required this.requestId,
    required this.status,
    required this.createdAt,
    required this.assignedAt,
    required this.pickedUpAt,
    required this.deliveredAt,
    this.kind,
    this.weight,
    this.price,
  });

  bool get isUnassigned => status == 'unassigned';
  bool get isAssigned => status == 'assigned';
  bool get isDelivered => status == 'delivered';

  bool get isOrderDelivery =>
      kind == 'order' || (kind == null && orderId != null);
  bool get isRequestDelivery =>
      kind == 'request' || (kind == null && requestId != null);

  String get statusLabel {
    switch (status) {
      case 'unassigned':
        return 'Unassigned';
      case 'assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked up';
      case 'in_transit':
        return 'In transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Optional helper for UI display
  String get kindLabel {
    if (isOrderDelivery) return 'Order';
    if (isRequestDelivery) return 'Request';
    return 'Delivery';
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return Delivery(
      id: json['id'] as int,
      origin: (json['origin'] as String?) ?? '',
      destination: (json['destination'] as String?) ?? '',
      driverId: json['driver_id'] as int?,
      vehicleId: json['vehicle_id'] as int?,
      orderId: json['order_id'] as int?,
      requestId: json['request_id'] as int?,
      status: (json['status'] as String?) ?? 'unassigned',
      createdAt: (json['created_at'] as num).toInt(),
      assignedAt: (json['assigned_at'] as num?)?.toInt(),
      pickedUpAt: (json['picked_up_at'] as num?)?.toInt(),
      deliveredAt: (json['delivered_at'] as num?)?.toInt(),

      // ✅ NEW
      kind: json['kind'] as String?, // backend sends "order" | "request"
      weight: toDouble(json['weight']),
      price: toDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'origin': origin,
    'destination': destination,
    'driver_id': driverId,
    'vehicle_id': vehicleId,
    'order_id': orderId,
    'request_id': requestId,
    'status': status,
    'created_at': createdAt,
    'assigned_at': assignedAt,
    'picked_up_at': pickedUpAt,
    'delivered_at': deliveredAt,

    // ✅ NEW
    'kind': kind,
    'weight': weight,
    'price': price,
  };
}
