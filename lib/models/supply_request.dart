// lib/models/supply_request.dart
import 'package:green_chain_v1/models/delivery.dart';

class Supply {
  final int id;
  final double weight;
  final int farmerId;
  final int productId;

  Supply({
    required this.id,
    required this.weight,
    required this.farmerId,
    required this.productId,
  });

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
      farmerId: json['farmer_id'] as int,
      productId: json['product_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'farmer_id': farmerId,
    'product_id': productId,
  };
}

class FarmInfo {
  final int farmerId;
  final String farmerUsername;
  final String farmerFirstName;
  final String farmerLastName;
  final String? farmName;
  final String? farmLocation;

  FarmInfo({
    required this.farmerId,
    required this.farmerUsername,
    required this.farmerFirstName,
    required this.farmerLastName,
    this.farmName,
    this.farmLocation,
  });

  factory FarmInfo.fromJson(Map<String, dynamic> json) {
    return FarmInfo(
      farmerId: json['farmer_id'] as int,
      farmerUsername: json['farmer_username'] as String,
      farmerFirstName: json['farmer_first_name'] as String,
      farmerLastName: json['farmer_last_name'] as String,
      farmName: json['farm_name'] as String?,
      farmLocation: json['farm_location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'farmer_id': farmerId,
    'farmer_username': farmerUsername,
    'farmer_first_name': farmerFirstName,
    'farmer_last_name': farmerLastName,
    'farm_name': farmName,
    'farm_location': farmLocation,
  };
}

class StallInfo {
  final int stallId;
  final String stallName;
  final String stallLocation;
  final String stallRepresentative;

  StallInfo({
    required this.stallId,
    required this.stallName,
    required this.stallLocation,
    required this.stallRepresentative,
  });

  factory StallInfo.fromJson(Map<String, dynamic> json) {
    return StallInfo(
      stallId: json['stall_id'] as int,
      stallName: json['stall_name'] as String,
      stallLocation: json['stall_location'] as String,
      stallRepresentative: json['stall_representative'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'stall_id': stallId,
    'stall_name': stallName,
    'stall_location': stallLocation,
    'stall_representative': stallRepresentative,
  };
}

class RequestWithContext {
  final int id;
  final double price;
  final String method; // gcash/cash
  final String status; // processing/accepted/rejected/completed
  final int supplyId;
  final int demandId;
  final FarmInfo farm;
  final StallInfo stall;

  /// ✅ NEW: present only when accepted transition (PATCH /requests/:id)
  final Delivery? delivery;

  RequestWithContext({
    required this.id,
    required this.price,
    required this.method,
    required this.status,
    required this.supplyId,
    required this.demandId,
    required this.farm,
    required this.stall,
    this.delivery,
  });

  factory RequestWithContext.fromJson(Map<String, dynamic> json) {
    return RequestWithContext(
      id: json['id'] as int,
      price: (json['price'] as num).toDouble(),
      method: json['method'] as String,
      status: (json['status'] as String?) ?? 'processing',
      supplyId: json['supply_id'] as int,
      demandId: json['demand_id'] as int,
      farm: FarmInfo.fromJson(json['farm'] as Map<String, dynamic>),
      stall: StallInfo.fromJson(json['stall'] as Map<String, dynamic>),
      delivery: json['delivery'] == null
          ? null
          : Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'price': price,
    'method': method,
    'status': status,
    'supply_id': supplyId,
    'demand_id': demandId,
    'farm': farm.toJson(),
    'stall': stall.toJson(),
    'delivery': delivery?.toJson(),
  };
}

/// Response for POST /supplies: { "supply": {...}, "request": {...} }
class SupplyAndRequestResponse {
  final Supply supply;
  final RequestWithContext request;

  SupplyAndRequestResponse({required this.supply, required this.request});

  factory SupplyAndRequestResponse.fromJson(Map<String, dynamic> json) {
    return SupplyAndRequestResponse(
      supply: Supply.fromJson(json['supply'] as Map<String, dynamic>),
      request: RequestWithContext.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'supply': supply.toJson(),
    'request': request.toJson(),
  };
}
