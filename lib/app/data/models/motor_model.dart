class MotorModel {
  final String? id;
  final String? userId;
  final String? brand;
  final String? model;
  final int? year;
  final String? licensePlate;
  final String? color;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  MotorModel({
    this.id,
    this.userId,
    this.brand,
    this.model,
    this.year,
    this.licensePlate,
    this.color,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory MotorModel.fromJson(Map<String, dynamic> json) {
    return MotorModel(
      id: json['_id'],
      userId: json['userId'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['licensePlate'],
      color: json['color'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class MotorResponse {
  final bool success;
  final List<MotorModel> data;

  MotorResponse({required this.success, required this.data});

  factory MotorResponse.fromJson(Map<String, dynamic> json) {
    return MotorResponse(
      success: json['success'],
      data:
          (json['data'] as List)
              .map((item) => MotorModel.fromJson(item))
              .toList(),
    );
  }
}
