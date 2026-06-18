import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/data/services/theme_services.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class ProfileController extends GetxController {
  final AuthService authservice;
  final ProfileProvider provider;
  final box = GetStorage();
  ProfileController({required this.provider, required this.authservice});

  var users = UserModel().obs;
  var isLoading = false.obs;

  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    isDarkMode.value = box.read('isDarkMode') ?? false;
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    ThemeService()
        .switchTheme(); // Memanggil service tema yang kita buat sebelumnya
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchProfile();
      if (response.isOk && response.body != null) {
        users.value = UserModel.fromJson(response.body['data']);
      } else {
        CustomSnackbar.error(
          'Error',
          response.body?['message'] ?? 'Gagal mengambil data profil',
        );
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal mengambil data profil');
    } finally {
      isLoading.value = false;
    }
  }

  void editProfile() {
    Get.toNamed('/edit-profile', arguments: users.value);
  }

  void logout() async {
    // 1. Amankan proses FCM dengan try-catch
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await Get.find<FCMService>().unregisterFcmToken(fcmToken);
        debugPrint("🔔 Token FCM berhasil dihapus dari backend.");
      }
      await FirebaseMessaging.instance.deleteToken();
      debugPrint("🗑️ Cache token FCM lokal berhasil dihancurkan.");
    } catch (e) {
      // Jika error SERVICE_NOT_AVAILABLE muncul, sistem akan masuk ke sini
      debugPrint("⚠️ Gagal memproses FCM saat logout: $e");
    }

    // 2. Proses logout lokal dan navigasi AKAN TETAP JALAN meskipun FCM error
    authservice.logout();
    Get.offAllNamed('/login');
  }
}
