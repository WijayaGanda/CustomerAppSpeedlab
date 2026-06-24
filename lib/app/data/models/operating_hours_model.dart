class OperatingHourModel {
  final int dayIndex;
  final String dayName;
  final bool isOpen;
  final List<TimeSlot> timeSlots;

  OperatingHourModel({
    required this.dayIndex,
    required this.dayName,
    required this.isOpen,
    required this.timeSlots,
  });

  // Konversi dari JSON (Backend) ke Object Dart
  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      dayIndex: json['dayIndex'] ?? 0,
      dayName: json['dayName'] ?? '',
      isOpen: json['isOpen'] ?? false,
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
      'dayIndex': dayIndex,
      'dayName': dayName,
      'isOpen': isOpen,
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
