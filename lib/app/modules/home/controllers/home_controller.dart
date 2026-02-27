import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final MotorcyclesProvider motorProvider;
  final authService = Get.find<AuthService>();
  final dashC = Get.find<DashboardController>();
  var motors = <MotorModel>[].obs;
  final isLoading = false.obs;

  HomeController({required this.motorProvider});

  @override
  void onInit() {
    super.onInit();
    // Delay lebih lama untuk memastikan GetConnect sudah fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchMyMotors();
    });
  }

  Future<void> fetchMyMotors({int retryCount = 0}) async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Fetching motors data... (Attempt ${retryCount + 1})');

      final response = await motorProvider.fetchMyMotors();

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      // Jika response null (koneksi belum siap), retry
      if (response.statusCode == null && retryCount < 3) {
        debugPrint(
          '⚠️ Connection not ready, retrying in ${500 * (retryCount + 1)}ms...',
        );
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return fetchMyMotors(retryCount: retryCount + 1);
      }

      if (response.isOk &&
          response.body != null &&
          response.body['data'] != null) {
        final motorResponse = MotorResponse.fromJson(response.body);
        if (motorResponse.success) {
          motors.value = motorResponse.data;
          debugPrint('✅ Successfully loaded ${motors.length} motors');
        } else {
          debugPrint('❌ Motor response not successful');
          CustomSnackbar.error("Error", 'Gagal mengambil data motor');
        }
      } else {
        debugPrint('❌ Response not OK or body null');
        CustomSnackbar.error(
          "Error",
          response.body?['message'] ?? 'Gagal mengambil data motor',
        );
      }
    } catch (e, stackTrace) {
      // Retry jika exception dan belum 3x
      if (retryCount < 3) {
        debugPrint('⚠️ Exception, retrying... Error: $e');
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return fetchMyMotors(retryCount: retryCount + 1);
      }
      debugPrint('❌ Exception in fetchMyMotors: $e');
      debugPrint('Stack trace: $stackTrace');
      CustomSnackbar.error("Error", 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void moveToAddMotor() {
    Get.toNamed('/add-motor');
  }

  // void moveToBooking(MotorModel motor) {
  //   Get.toNamed('/booking', arguments: motor.id);
  // }
}
