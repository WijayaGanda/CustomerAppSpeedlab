import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/notification/controllers/notification_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';

class FCMService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotifProvider _notifProvider = Get.put(NotifProvider());

  // final dashC = Get.find<DashboardController>();

  Future<FCMService> init() async {
    // Pastikan firebase sudah siap (aman kalau dipanggil lagi)
    await Firebase.initializeApp();

    // 1) Permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 Permission: ${settings.authorizationStatus}');

    // 2) Ambil token awal
    await _registerCurrentToken();

    // 3) Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('🔔 Foreground message masuk');
      final notif = message.notification;

      if (notif != null) {
        // In-app popup (bukan system notification)
        Get.snackbar(
          notif.title ?? 'Notifikasi Baru',
          notif.body ?? '',
          backgroundColor: Colors.white,
          colorText: Colors.black,
          icon: const Icon(Icons.notifications_active, color: Colors.blue),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(15),
          snackPosition: SnackPosition.TOP,
        );
        await Get.find<NotificationController>().fetchNotifications();
      }
    });

    // 4) Klik notifikasi (background -> app open)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _handleNotificationTap(message);
    });

    // 5) Klik notifikasi saat app terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // 6) Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 Token FCM diperbarui: $newToken");
      await sendFcmTokenToBackend(newToken);
    });

    return this;
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint("🔔 FCM Token: $token");

      if (token != null) {
        await sendFcmTokenToBackend(token);
      } else {
        debugPrint("❌ Token FCM null");
      }
    } catch (e) {
      debugPrint("❌ Gagal ambil token FCM: $e");
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final relatedId = data['relatedId'];

    debugPrint("🔔 Notification tapped. type=$type relatedId=$relatedId");

    if (type == 'booking' && relatedId != null) {
      // Contoh:
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changePage(2);
        }

        if (Get.isRegistered<RiwayatBookingController>()) {
          Get.find<RiwayatBookingController>().openModalFromNotification(
            relatedId,
          );
        }
      });
    }
  }

  Future<void> sendFcmTokenToBackend(String fcmToken) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      String deviceId = 'Unknown ID';
      final platform = Platform.operatingSystem; // android / ios

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceName = '${info.manufacturer} ${info.model}';
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceName = info.name;
        deviceId = info.identifierForVendor ?? 'Unknown iOS ID';
      }

      final response = await _notifProvider.registerFcmToken({
        'fcmToken': fcmToken,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Token FCM tersimpan di backend");
      } else {
        debugPrint("❌ Gagal simpan token. Status: ${response.statusCode}");
        debugPrint("❌ Body: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error kirim token ke backend: $e");
    }
  }

  Future<void> unregisterFcmToken(String fcmToken) async {
    try {
      final response = await _notifProvider.unregisterFcmToken({
        'fcmToken': fcmToken,
      });
      debugPrint("🔔 Unregistering FCM Token: $fcmToken");
      if (response.statusCode == 200) {
        debugPrint("✅ Token FCM berhasil dihapus dari backend");
      } else {
        debugPrint("❌ Gagal hapus token. Status: ${response.statusCode}");
        debugPrint("❌ Body: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error unregister token: $e");
    }
  }
}
