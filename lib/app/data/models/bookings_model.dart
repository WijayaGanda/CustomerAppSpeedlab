class BookingsResponse {
  final bool? success;
  // Ubah menjadi List karena dari API berupa Array [...]
  final List<BookingsModel>? data;

  BookingsResponse({this.success, this.data});

  factory BookingsResponse.fromJson(Map<String, dynamic> json) {
    List<BookingsModel> bookingsList = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        bookingsList = List<BookingsModel>.from(
          json['data'].map((x) => BookingsModel.fromJson(x)),
        );
      } else if (json['data'] is Map) {
        bookingsList = [BookingsModel.fromJson(json['data'])];
      }
    }

    return BookingsResponse(success: json['success'], data: bookingsList);
  }
}

class SelectedAddon {
  final String? id;
  final String? name;
  final num? price;
  final int? quantity;
  final num? subtotal;

  SelectedAddon({this.id, this.name, this.price, this.quantity, this.subtotal});

  factory SelectedAddon.fromJson(Map<String, dynamic> json) {
    return SelectedAddon(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      subtotal: json['subtotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class BookingDetail {
  final String? serviceId;
  final String? serviceName;
  final num? basePrice;
  final String? selectedVariant;
  final List<SelectedAddon>? selectedAddons;
  final num? addonsTotal;
  final num? subtotal;

  BookingDetail({
    this.serviceId,
    this.serviceName,
    this.basePrice,
    this.selectedVariant,
    this.selectedAddons,
    this.addonsTotal,
    this.subtotal,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      basePrice: json['basePrice'],
      selectedVariant: json['selectedVariant'],
      selectedAddons:
          json['selectedAddons'] != null
              ? List<SelectedAddon>.from(
                json['selectedAddons'].map((x) => SelectedAddon.fromJson(x)),
              )
              : [],
      addonsTotal: json['addonsTotal'],
      subtotal: json['subtotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'basePrice': basePrice,
      'selectedVariant': selectedVariant,
      'selectedAddons': selectedAddons?.map((x) => x.toJson()).toList(),
      'addonsTotal': addonsTotal,
      'subtotal': subtotal,
    };
  }
}

class BookingsModel {
  final String? id;
  final dynamic motorcycleId; // Bisa string ID atau Object
  final List<dynamic>? serviceIds;
  final List<BookingDetail>? bookingDetails;
  final DateTime? bookingDate;
  final String? bookingTime;
  final String? complaint;
  final String? status;
  final num? servicePrice;
  final num? sparepartPrice;
  final num? totalPrice;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingsModel({
    this.id,
    this.motorcycleId,
    this.serviceIds,
    this.bookingDetails,
    this.bookingDate,
    this.bookingTime,
    this.complaint,
    this.status,
    this.servicePrice,
    this.sparepartPrice,
    this.totalPrice,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingsModel.fromJson(Map<String, dynamic> json) {
    return BookingsModel(
      id: json['_id'],
      motorcycleId: json['motorcycleId'],
      serviceIds: json['serviceIds'],
      bookingDetails:
          json['bookingDetails'] != null
              ? List<BookingDetail>.from(
                json['bookingDetails'].map((x) => BookingDetail.fromJson(x)),
              )
              : [],
      bookingDate:
          json['bookingDate'] != null
              ? DateTime.tryParse(json['bookingDate'])
              : null,
      bookingTime: json['bookingTime']?.toString(),
      complaint: json['complaint'],
      status: json['status'],
      servicePrice: json['servicePrice'],
      sparepartPrice:
          json['sparepartsPrice'], // Sesuai JSON, pakai 'sparepartsPrice'
      totalPrice: json['totalPrice'],
      notes: json['notes'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }
}
