import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/services/fcm_service.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final authservice = Get.find<AuthService>();
  final ProfileProvider provider;
  ProfileController({required this.provider});

  var users = UserModel().obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchProfile();
      if (response.isOk && response.body != null) {
        users.value = UserModel.fromJson(response.body['data']);
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Gagal mengambil data profil',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void editProfile() {
    Get.toNamed('/edit-profile', arguments: users.value);
  }

  void logout() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await Get.find<FCMService>().unregisterFcmToken(fcmToken);
      debugPrint("🔔 Token FCM berhasil dihapus dari backend.");
    }
    authservice.logout();
    Get.offAllNamed('/login');
  }
}
