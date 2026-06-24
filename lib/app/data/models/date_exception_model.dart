class DateExceptionModel {
  final String id;
  final String date;
  final bool isOpen;
  final String note;
  final List<TimeSlot> timeSlots;

  DateExceptionModel({
    required this.id,
    required this.date,
    required this.isOpen,
    required this.note,
    required this.timeSlots,
  });

  // Konversi dari JSON (Backend) ke Object Dart
  factory DateExceptionModel.fromJson(Map<String, dynamic> json) {
    return DateExceptionModel(
      id: json['_id'] ?? '',
      date: json['date'] ?? '',
      isOpen: json['isOpen'] ?? false,
      note: json['note'] ?? '',
      timeSlots:
          json['timeSlots'] != null
              ? List<TimeSlot>.from(
                json['timeSlots'].map((x) => TimeSlot.fromJson(x)),
              )
              : [],
    );
  }

  // Konversi dari Object Dart ke JSON (untuk dikirim ke Backend nanti)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date,
      'isOpen': isOpen,
      'note': note,
      'timeSlots': List<dynamic>.from(timeSlots.map((x) => x.toJson())),
    };
  }
}

class TimeSlot {
  final String openTime;
  final String closeTime;

  TimeSlot({required this.openTime, required this.closeTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'openTime': openTime, 'closeTime': closeTime};
  }
}
