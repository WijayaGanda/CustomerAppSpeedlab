class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int estimatedDuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDuration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      estimatedDuration: json['estimatedDuration'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class ServiceResponse {
  final bool success;
  final List<ServiceModel> data;

  ServiceResponse({required this.success, required this.data});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'],
      data:
          (json['data'] as List)
              .map((serviceJson) => ServiceModel.fromJson(serviceJson))
              .toList(),
    );
  }
}
