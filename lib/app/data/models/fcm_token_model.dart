// import 'package:flutter/foundation.dart';

class FcmTokenResponse {
  final bool? success;
  final List<FcmTokenModel>? data;

  FcmTokenResponse({required this.success, this.data});

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponse(
      success: json['success'],
      data:
          json['data'] != null
              ? List<FcmTokenModel>.from(
                json['data'].map((x) => FcmTokenModel.fromJson(x)),
              )
              : null,
    );
  }
}

class FcmTokenModel {
  final String? fcmToken;
  final String? deviceId;
  final String? deviceName;
  final String? platform;
  final bool? isActive;
  final Map<String, dynamic>? userId;

  FcmTokenModel({
    this.fcmToken,
    this.deviceId,
    this.deviceName,
    this.platform,
    this.isActive,
    this.userId,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      fcmToken: json['token'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      platform: json['platform'],
      isActive: json['is_active'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': fcmToken,
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'is_active': isActive,
      'user_id': userId,
    };
  }
}
