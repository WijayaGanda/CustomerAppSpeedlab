import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class AddMotorController extends GetxController {
  final provider = Get.find<MotorcyclesProvider>();
  final brand = TextEditingController();
  final model = TextEditingController();
  final year = TextEditingController();
  final licensePlate = TextEditingController();
  final color = TextEditingController();

  final isLoading = false.obs;

  void addMotor() async {
    if (brand.text.isEmpty ||
        model.text.isEmpty ||
        year.text.isEmpty ||
        licensePlate.text.isEmpty ||
        color.text.isEmpty) {
      CustomSnackbar.error("Oops", "Semua field harus diisi");
      return;
    }
    try {
      isLoading.value = true;
      final response = await provider.addMotorCycles({
        "brand": brand.text,
        "model": model.text,
        "year": year.text,
        "licensePlate": licensePlate.text,
        "color": color.text,
      });

      if (response.isOk && response.body != null) {
        CustomSnackbar.success("Sukses", "Motor berhasil ditambahkan");
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error(
          "Error",
          response.body['message'] ?? 'Gagal menambahkan motor',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    brand.clear();
    model.clear();
    year.clear();
    licensePlate.clear();
    color.clear();
  }

  // @override
  // void onClose() {
  //   brand.dispose();
  //   model.dispose();
  //   year.dispose();
  //   licensePlate.dispose();
  //   color.dispose();
  //   super.onClose();
  // }
}
