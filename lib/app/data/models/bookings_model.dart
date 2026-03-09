class BookingsResponse {
  final bool? success;
  // Ubah menjadi List karena dari API berupa Array [...]
  final List<BookingsModel>? data;

  BookingsResponse({this.success, this.data});

  factory BookingsResponse.fromJson(Map<String, dynamic> json) {
    return BookingsResponse(
      success: json['success'],
      data:
          json['data'] != null
              ? List<BookingsModel>.from(
                json['data'].map((x) => BookingsModel.fromJson(x)),
              )
              : [],
    );
  }
}

class BookingsModel {
  final String? id;
  final Map<String, dynamic>?
  motorcycleId; // Diubah jadi Map karena API mengirim object
  final List<dynamic>?
  serviceIds; // Diubah jadi List karena API mengirim array object
  final DateTime? bookingDate;
  final DateTime?
  bookingTime; // Gunakan DateTime untuk menampung format ISO dari API
  final String? complaint;
  final String? status;
  final int? totalPrice;
  final String? notes;
  // final List<dynamic>?
  // verifiedBy; // Tambahkan field untuk menampung data teknisi yang memeriksa

  // Hapus 'required' agar tidak crash jika API tidak mengirimkan salah satu data
  BookingsModel({
    this.id,
    this.motorcycleId,
    this.serviceIds,
    this.bookingDate,
    this.bookingTime,
    this.complaint,
    this.status,
    this.totalPrice,
    this.notes,
    // this.verifiedBy,
  });

  factory BookingsModel.fromJson(Map<String, dynamic> json) {
    return BookingsModel(
      id: json['_id'],
      motorcycleId: json['motorcycleId'],
      serviceIds: json['serviceIds'],
      // Gunakan tryParse agar aman dari error format tanggal
      bookingDate:
          json['bookingDate'] != null
              ? DateTime.tryParse(json['bookingDate'])
              : null,
      bookingTime:
          json['bookingTime'] != null
              ? DateTime.tryParse(json['bookingTime'])
              : null,
      complaint: json['complaint'],
      status: json['status'],
      totalPrice: json['totalPrice'],
      notes: json['notes'],
      // verifiedBy: json['verifiedBy'],
    );
  }
}
