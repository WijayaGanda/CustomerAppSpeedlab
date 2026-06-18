import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class OtpPageController extends GetxController {
  final AuthProvider provider;
  OtpPageController({required this.provider});

  var currentText = "".obs;
  var isLoading = false.obs;

  final email = Get.arguments['email'] ?? '';

  Future<void> verifyOtp() async {
    if (currentText.value.length != 6) {
      CustomSnackbar.error('Error', 'Kode OTP harus terdiri dari 6 digit');
      return;
    }

    isLoading.value = true;
    try {
      final response = await provider.verifyOtp({'otp': currentText.value});

      if (!response.isOk) {
        CustomSnackbar.error('Error', 'Gagal memverifikasi kode OTP');
        print('Response error: ${response.body}');
        return;
      }
      await Future.delayed(Duration(seconds: 2));
      CustomSnackbar.success('Sukses', 'Kode OTP berhasil diverifikasi');
      Get.toNamed('/change-password', arguments: {'otp': currentText.value});
      // Lanjutkan ke halaman berikutnya atau lakukan tindakan lain
    } catch (e) {
      // Get.snackbar('Error', 'Gagal memverifikasi kode OTP');
      print('error aslinya: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
