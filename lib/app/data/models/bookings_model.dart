import 'package:flutter/material.dart';

class BookingsModel {
  final String id;
  final String motorcycleId;
  final String serviceIds;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  final String complaint;
  final String notes;

  BookingsModel({
    required this.id,
    required this.motorcycleId,
    required this.serviceIds,
    required this.bookingDate,
    required this.bookingTime,
    required this.complaint,
    required this.notes,
  });

  factory BookingsModel.fromJson(Map<String, dynamic> json) {
    return BookingsModel(
      id: json['_id'],
      motorcycleId: json['motorcycleId'],
      serviceIds: json['serviceIds'],
      bookingDate: DateTime.parse(json['bookingDate']),
      bookingTime: TimeOfDay(
        hour: int.parse(json['bookingTime'].split(':')[0]),
        minute: int.parse(json['bookingTime'].split(':')[1]),
      ),
      complaint: json['complaint'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'motorcycleId': motorcycleId,
      'serviceIds': serviceIds,
      'bookingDate': bookingDate.toIso8601String(),
      'bookingTime': '${bookingTime.hour}:${bookingTime.minute}',
      'complaint': complaint,
      'notes': notes,
    };
  }
}

class BookingsResponse {
  final bool success;
  final BookingsModel data;

  BookingsResponse({required this.success, required this.data});

  factory BookingsResponse.fromJson(Map<String, dynamic> json) {
    return BookingsResponse(
      success: json['success'],
      data: BookingsModel.fromJson(json['data']),
    );
  }
}
