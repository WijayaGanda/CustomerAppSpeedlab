import 'package:flutter/foundation.dart';

class WarrantyModel {
  final String? id;
  final Map<String, dynamic>? motorcycleId;
  final Map<String, dynamic>? serviceHistoryId;
  final String? complaint;
  final String? notes;
  final String? status;
  final String? rejectionReason;
  final DateTime? claimDate;

  WarrantyModel({
    this.id,
    this.motorcycleId,
    this.serviceHistoryId,
    this.complaint,
    this.notes,
    this.status,
    this.rejectionReason,
    this.claimDate,
  });

  factory WarrantyModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedClaimDate;
    if (json['claimDate'] != null && json['claimDate'].toString().isNotEmpty) {
      try {
        parsedClaimDate = DateTime.parse(json['claimDate'].toString());
      } catch (e) {
        debugPrint('Error parsing claimDate: $e');
      }
    }

    return WarrantyModel(
      id: json['_id'],
      motorcycleId: json['motorcycleId'],
      serviceHistoryId: json['serviceHistoryId'],
      complaint: json['complaint'],
      notes: json['notes'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      claimDate: parsedClaimDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'motorcycleId': motorcycleId,
      'serviceHistoryId': serviceHistoryId,
      'complaint': complaint,
      'notes': notes,
      'status': status,
      'rejectionReason': rejectionReason,
      'claimDate': claimDate,
    };
  }
}

class WarrantyResponse {
  final bool success;
  final List<WarrantyModel> data;

  WarrantyResponse({required this.success, required this.data});

  factory WarrantyResponse.fromJson(Map<String, dynamic> json) {
    return WarrantyResponse(
      success: json['success'],
      data:
          (json['data'] as List)
              .map((warrantyJson) => WarrantyModel.fromJson(warrantyJson))
              .toList(),
    );
  }
}
