// lib/api/deliveries_api.dart
import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/delivery.dart';

Future<List<Delivery>> fetchDeliveries({
  String scope = 'unassigned', // 'unassigned' | 'mine'
  String? status,
}) {
  final qs = <String>['scope=$scope'];
  if (status != null && status.trim().isNotEmpty) {
    qs.add('status=${Uri.encodeQueryComponent(status.trim())}');
  }
  final path = '/deliveries?${qs.join('&')}';

  return apiClient.getJson<List<Delivery>>(
    path,
    parser: (json) {
      final list = (json as List<dynamic>? ?? const []);
      return list
          .map((e) => Delivery.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

Future<Delivery> fetchDeliveryById(int id) {
  return apiClient.getJson<Delivery>(
    '/deliveries/$id',
    parser: (json) => Delivery.fromJson(json as Map<String, dynamic>),
  );
}

Future<Delivery> assignDelivery({
  required int deliveryId,
  required int vehicleId,
}) {
  return apiClient.patchJson<Delivery>(
    '/deliveries/$deliveryId/assign',
    body: {'vehicle_id': vehicleId},
    parser: (json) => Delivery.fromJson(json as Map<String, dynamic>),
  );
}

Future<Delivery> updateDeliveryStatus({
  required int deliveryId,
  required String status, // picked_up | in_transit | delivered | cancelled
}) {
  return apiClient.patchJson<Delivery>(
    '/deliveries/$deliveryId/status',
    body: {'status': status},
    parser: (json) => Delivery.fromJson(json as Map<String, dynamic>),
  );
}
