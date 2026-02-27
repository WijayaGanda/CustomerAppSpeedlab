import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:flutter/material.dart ';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class RegisterController extends GetxController {
  final AuthProvider provider;
  RegisterController({required this.provider});

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final isLoading = false.obs;
  final isVisible = true.obs;

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }

  void register() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      CustomSnackbar.error("Error", "Semua field harus diisi");
      return;
    }

    isLoading.value = true;
    try {
      final response = await provider.register({
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'password': passwordCtrl.text,
        'phone': phoneCtrl.text,
        'address': addressCtrl.text,
      });

      if (response.isOk && response.body != null) {
        final res = LoginResponseModel.fromJson(response.body['data']);
        Get.find<AuthService>().login(res.token!, res.user!);
        CustomSnackbar.success("Sukses", "Registrasi berhasil");
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error(
          "Error",
          response.body['message'] ?? 'Registrasi gagal',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
