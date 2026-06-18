import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class ChangePasswordController extends GetxController {
  final AuthProvider provider;
  ChangePasswordController({required this.provider});

  final isLoading = false.obs;
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isVisibleNewPassword = true.obs;
  final isVisibleConfirmPassword = true.obs;

  final otp = Get.arguments['otp'] ?? '';

  void toggleNewPasswordVisibility() {
    isVisibleNewPassword.value = !isVisibleNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    isVisibleConfirmPassword.value = !isVisibleConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      CustomSnackbar.error('Error', 'Semua field harus diisi');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      CustomSnackbar.error('Error', 'Konfirmasi password tidak cocok');
      return;
    }

    try {
      isLoading.value = true;
      final response = await provider.resetPassword({
        'otp': otp,
        'newPassword': confirmPasswordController.text,
      });

      if (!response.isOk) {
        CustomSnackbar.error('Error', 'Gagal mengubah password');
        print('Response error: ${response.body}');
        return;
      }
      await Future.delayed(Duration(seconds: 2));
      CustomSnackbar.success('Sukses', 'Password berhasil diubah');
      Get.offAllNamed('/login');
      // Lanjutkan ke halaman berikutnya atau lakukan tindakan lain
    } catch (e) {
      print('error aslinya: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
