class Variant {
  final String name;
  final double priceModifier;
  final String description;

  Variant({
    required this.name,
    required this.priceModifier,
    required this.description,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      name: json['name'] ?? '',
      priceModifier:
          json['priceModifier'] != null
              ? (json['priceModifier'] as num).toDouble()
              : 0.0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priceModifier': priceModifier,
      'description': description,
    };
  }
}

class Addon {
  final String id;
  final String name;
  final double price;
  final String type;
  final String description;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      type: json['type'] ?? 'OPTIONAL',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'type': type,
      'description': description,
    };
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double basePrice;
  final List<Variant> variants;
  final List<Addon> availableAddons;
  final int estimatedDuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isWaitable;
  final int v;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.variants,
    required this.availableAddons,
    required this.estimatedDuration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isWaitable,
    required this.v,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      basePrice:
          json['basePrice'] != null
              ? (json['basePrice'] as num).toDouble()
              : 0.0,
      variants:
          (json['variants'] as List?)
              ?.map((v) => Variant.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      availableAddons:
          (json['availableAddons'] as List?)
              ?.map((a) => Addon.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedDuration: json['estimatedDuration'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      isWaitable: json['isWaitable'] ?? false,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'description': description,
      'basePrice': basePrice,
      'variants': variants.map((v) => v.toJson()).toList(),
      'availableAddons': availableAddons.map((a) => a.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isWaitable': isWaitable,
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
