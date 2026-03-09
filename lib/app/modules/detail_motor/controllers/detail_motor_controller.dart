import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class DetailMotorController extends GetxController {
  final BookingsProvider bookingsProvider;
  final MotorcyclesProvider motorcyclesProvider;

  var detailMotor = Rxn<MotorModel>();

  var isLoading = false.obs;
  var bookings = <BookingsModel>[].obs;

  DetailMotorController({
    required this.bookingsProvider,
    required this.motorcyclesProvider,
  });

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      detailMotor.value = Get.arguments as MotorModel;
      debugPrint("Menampilkan detail: ${detailMotor.value?.model}");
      // if (detailMotor.value?.id != null) {
      //   // Panggil fungsi API menggunakan ID tersebut
      //   fetchBookingByMotorId(detailMotor.value!.id.toString());
      // }
    }
  }

  Future<void> deleteMotor(String id) async {
    try {
      isLoading.value = true;
      final response = await motorcyclesProvider.deleteMotorcycle(id);
      if (response.statusCode == 200) {
        debugPrint("Motor berhasil dihapus: ID $id");
        CustomSnackbar.success("Berhasil", "Motor berhasil dihapus");
        Get.offAllNamed('/dashboard');
      } else {
        // Tampilkan pesan error ASLI dari backend jika ada
        String errorMsg = response.body?['message'] ?? "Gagal menghapus data";
        Get.snackbar("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e, stacktrace) {
      // TAMBAHKAN stacktrace
      // INI KUNCI UNTUK DEBUGGING
      debugPrint("=== ERROR ASLINYA ADALAH ===");
      debugPrint(e.toString());
      debugPrint("Lokasi Error: $stacktrace");
    } finally {
      isLoading.value = false;
    }
  }
}
