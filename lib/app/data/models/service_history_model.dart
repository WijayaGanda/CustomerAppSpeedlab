import 'dart:convert';

class ServiceHistoryResponse {
  final bool? success;
  // 1. UBAH: Menjadi objek tunggal, BUKAN List
  final ServiceHistoryModel? data;

  ServiceHistoryResponse({this.success, this.data});

  // 2. AMAN DARI ERROR STRING/MAP: Terima tipe dynamic
  factory ServiceHistoryResponse.fromJson(dynamic source) {
    Map<String, dynamic> json;
    if (source is String) {
      json = jsonDecode(source);
    } else {
      json = source as Map<String, dynamic>;
    }

    return ServiceHistoryResponse(
      success: json['success'],
      // 3. Parsing langsung sebagai satu objek
      data:
          json['data'] != null
              ? ServiceHistoryModel.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}

class ServiceHistoryModel {
  final String? id;
  // 4. UBAH: bookingId dkk diubah jadi Map karena API mengirim object {...}
  final Map<String, dynamic>? bookingId;
  final Map<String, dynamic>? userId;
  final Map<String, dynamic>? motorcycleId;
  final List<dynamic>? workPhotos;
  final List<dynamic>? serviceIds;

  final String? diagnosis;
  final String? workDone;
  final List<ServiceHistorySparePart>? spareParts;
  final String? mechanicName;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? servicePrice;
  final int? sparepartPrice;
  final int? totalPrice;
  final DateTime? warrantyExpiry;
  final String? notes;
  final String? status;
  final String? complaint;

  ServiceHistoryModel({
    this.id,
    this.bookingId,
    this.userId,
    this.motorcycleId,
    this.serviceIds,
    this.diagnosis,
    this.workDone,
    this.spareParts,
    this.mechanicName,
    this.startDate,
    this.endDate,
    this.servicePrice,
    this.sparepartPrice,
    this.totalPrice,
    this.warrantyExpiry,
    this.notes,
    this.status,
    this.complaint,
    this.workPhotos,
  });

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryModel(
      id: json['_id'],
      bookingId: json['bookingId'],
      userId: json['userId'],
      motorcycleId: json['motorcycleId'],
      workPhotos: json['workPhotos'],
      serviceIds: json['serviceIds'],
      diagnosis: json['diagnosis'],
      workDone: json['workDone'],
      spareParts:
          json['spareParts'] != null
              ? List<ServiceHistorySparePart>.from(
                (json['spareParts'] as List).map(
                  (item) => ServiceHistorySparePart.fromJson(item),
                ),
              )
              : [],
      mechanicName: json['mechanicName'],
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'])
              : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      servicePrice: json['servicePrice'],
      sparepartPrice: json['sparepartPrice'],
      totalPrice: json['totalPrice'],
      warrantyExpiry:
          json['warrantyExpiry'] != null
              ? DateTime.tryParse(json['warrantyExpiry'])
              : null,
      notes: json['notes'],
      status: json['status'],
      complaint: json['complaint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'userId': userId,
      'motorcycleId': motorcycleId,
      'serviceIds': serviceIds,
      'diagnosis': diagnosis,
      'workDone': workDone,
      'spareParts':
          spareParts != null
              ? List<dynamic>.from(spareParts!.map((item) => item.toJson()))
              : [],
      'mechanicName': mechanicName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'servicePrice': servicePrice,
      'sparepartPrice': sparepartPrice,
      'totalPrice': totalPrice,
      'warrantyExpiry': warrantyExpiry?.toIso8601String(),
      'notes': notes,
      'status': status,
      'complaint': complaint,
      'workPhotos': workPhotos,
    };
  }
}

class ServiceHistorySparePart {
  final String? id; // Tambahan _id dari JSON
  final String? name;
  final int? price;
  final int? quantity;

  ServiceHistorySparePart({this.id, this.name, this.price, this.quantity});

  factory ServiceHistorySparePart.fromJson(Map<String, dynamic> json) {
    return ServiceHistorySparePart(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'price': price, 'quantity': quantity};
  }
}
