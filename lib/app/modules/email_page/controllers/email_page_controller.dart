import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class EmailPageController extends GetxController {
  final AuthProvider provider;
  EmailPageController({required this.provider});

  final isLoading = false.obs;
  final emailController = TextEditingController();

  Future<void> sendResetCode() async {
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      final response = await provider.forgotPassword({
        'email': emailController.text,
      });
      if (!response.isOk) {
        CustomModal.showErrorDialog(
          title: 'Error',
          message: 'Gagal mengirim kode reset',
        );
        return;
      }
      // Simulasi delay untuk proses pengiriman kode reset
      await Future.delayed(Duration(seconds: 2));
      CustomSnackbar.success(
        'Sukses',
        'Kode reset berhasil dikirim ke email Anda',
      );
      Get.toNamed('/otp-page', arguments: {'email': emailController.text});
    } catch (e) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'Gagal mengirim kode reset',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
