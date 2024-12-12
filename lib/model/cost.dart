part of 'model.dart';

class ShippingCost extends Equatable {
  final String code;
  final String name;
  final List<ShippingService> costs;

  ShippingCost({
    required this.code,
    required this.name,
    required this.costs,
  });

  factory ShippingCost.fromJson(Map<String, dynamic> json) {
    return ShippingCost(
      code: json['code'],
      name: json['name'],
      costs: (json['costs'] as List)
          .map((serviceJson) => ShippingService.fromJson(serviceJson))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [code, name, costs]; // Implemented props
}

class ShippingService {
  final String service;
  final String description;
  final List<ShippingCostDetail> cost;

  ShippingService({
    required this.service,
    required this.description,
    required this.cost,
  });

  factory ShippingService.fromJson(Map<String, dynamic> json) {
    return ShippingService(
      service: json['service'],
      description: json['description'],
      cost: (json['cost'] as List)
          .map((costJson) => ShippingCostDetail.fromJson(costJson))
          .toList(),
    );
  }
}

class ShippingCostDetail {
  final int value;
  final String etd;
  final String note;

  ShippingCostDetail({
    required this.value,
    required this.etd,
    required this.note,
  });

  factory ShippingCostDetail.fromJson(Map<String, dynamic> json) {
    return ShippingCostDetail(
      value: json['value'],
      etd: json['etd'] ?? '',
      note: json['note'] ?? '',
    );
  }
}
