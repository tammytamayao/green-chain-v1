// lib/api/request_api.dart

import 'package:green_chain_v1/api/api_client.dart';
import 'package:green_chain_v1/models/supply_request.dart';

/// GET /requests
/// - For farmers: requests linked to their supplies
/// - For disposers: requests linked to demands in their stall
Future<List<RequestWithContext>> fetchRequests() {
  return apiClient.getJson<List<RequestWithContext>>(
    '/requests',
    parser: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => RequestWithContext.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

/// GET /requests/:id
Future<RequestWithContext> fetchRequestById(int id) {
  return apiClient.getJson<RequestWithContext>(
    '/requests/$id',
    parser: (json) => RequestWithContext.fromJson(json as Map<String, dynamic>),
  );
}

/// PATCH /requests/:id  (disposer-only: change status)
Future<RequestWithContext> updateRequestStatus({
  required int id,
  required String
  status, // "processing" | "accepted" | "rejected" | "completed"
}) {
  return apiClient.patchJson<RequestWithContext>(
    '/requests/$id',
    body: {'status': status},
    parser: (json) => RequestWithContext.fromJson(json as Map<String, dynamic>),
  );
}

/// DELETE /requests/:id  (farmer-only; only when status == "processing")
Future<void> deleteRequest(int id) {
  return apiClient.delete('/requests/$id', expectedStatus: 204);
}
