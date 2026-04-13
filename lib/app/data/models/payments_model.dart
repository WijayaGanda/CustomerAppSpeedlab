class PaymentResponse {
  final String token;
  final String redirectUrl;

  PaymentResponse({required this.token, required this.redirectUrl});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      token: json['token'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
    );
  }
}

class PaymentStatusResponse {
  final String orderId;
  final String bookingId;
  final int grossAmount;
  final String transactionStatus; // pending, settlement, cancel, expire, deny
  final String paymentType; // bank_transfer, gopay, credit_card, etc
  final String snapToken;
  final String snapRedirectUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentStatusResponse({
    required this.orderId,
    required this.bookingId,
    required this.grossAmount,
    required this.transactionStatus,
    required this.paymentType,
    required this.snapToken,
    required this.snapRedirectUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSettled => transactionStatus == 'settlement';
  bool get isPending => transactionStatus == 'pending';
  bool get isExpired => transactionStatus == 'expire';
  bool get isCancelled => transactionStatus == 'cancel';

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      orderId: json['orderId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      grossAmount: json['grossAmount'] ?? 0,
      transactionStatus: json['transactionStatus'] ?? 'pending',
      paymentType: json['paymentType'] ?? '',
      snapToken: json['snapToken'] ?? '',
      snapRedirectUrl: json['snapRedirectUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class PaymentHistoryItem {
  final String id;
  final String orderId;
  final String bookingId;
  final int grossAmount;
  final String transactionStatus;
  final String paymentType;
  final DateTime createdAt;

  PaymentHistoryItem({
    required this.id,
    required this.orderId,
    required this.bookingId,
    required this.grossAmount,
    required this.transactionStatus,
    required this.paymentType,
    required this.createdAt,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      grossAmount: json['grossAmount'] ?? 0,
      transactionStatus: json['transactionStatus'] ?? '',
      paymentType: json['paymentType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
