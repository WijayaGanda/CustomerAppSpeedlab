import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class EditMotorController extends GetxController {
  final MotorcyclesProvider provider;
  var motor = Rxn<MotorModel>();

  var isLoading = false.obs;
  late TextEditingController brandCtrl;
  late TextEditingController modelCtrl;
  late TextEditingController yearCtrl;
  late TextEditingController licensePlateCtrl;
  late TextEditingController colorCtrl;

  EditMotorController({required this.provider});

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      motor.value = Get.arguments as MotorModel;
      debugPrint("EditMotorController received motor: ${motor.value?.model}");
      brandCtrl = TextEditingController(text: motor.value?.brand ?? '');
      modelCtrl = TextEditingController(text: motor.value?.model ?? '');
      yearCtrl = TextEditingController(
        text: motor.value?.year?.toString() ?? '',
      );
      licensePlateCtrl = TextEditingController(
        text: motor.value?.licensePlate ?? '',
      );
      colorCtrl = TextEditingController(text: motor.value?.color ?? '');
    }
  }

  Future<void> updateMotor(String id) async {
    try {
      isLoading.value = true;
      if (brandCtrl.text.isEmpty ||
          modelCtrl.text.isEmpty ||
          yearCtrl.text.isEmpty ||
          licensePlateCtrl.text.isEmpty ||
          colorCtrl.text.isEmpty) {
        CustomSnackbar.error("Error", "Semua field harus diisi");
        return;
      }
      final response = await provider.updateMotorcycle(id, {
        'brand': brandCtrl.text,
        'model': modelCtrl.text,
        'year': int.tryParse(yearCtrl.text) ?? 0,
        'licensePlate': licensePlateCtrl.text,
        'color': colorCtrl.text,
      });
      if (response.statusCode == 200) {
        debugPrint("Motor berhasil diperbarui: ID ${motor.value!.id}");
        CustomSnackbar.success("Berhasil", "Motor berhasil diperbarui");
        Get.offAllNamed('/dashboard');
      } else {
        String errorMsg = response.body?['message'] ?? "Gagal memperbarui data";
        Get.snackbar("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e, stacktrace) {
      debugPrint("=== ERROR ASLINYA ADALAH ===");
      debugPrint(e.toString());
      debugPrint("Lokasi Error: $stacktrace");
    } finally {
      isLoading.value = false;
    }
  }
}
