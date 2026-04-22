import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
// import 'package:speedlab_pelanggan/app/data/services/tutorial_service.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final MotorcyclesProvider motorProvider;
  final ServiceProvider serviceProvider;
  final authService = Get.find<AuthService>();
  final dashC = Get.find<DashboardController>();
  var motors = <MotorModel>[].obs;
  var service = <ServiceModel>[].obs;
  final isLoading = false.obs;

  final box = GetStorage();

  final GlobalKey keyProfile = GlobalKey();
  final GlobalKey keyTambahMotor = GlobalKey();
  final GlobalKey keyLayanan = GlobalKey();
  final GlobalKey keyRefresh = GlobalKey();
  final GlobalKey keyLayananList = GlobalKey();
  final GlobalKey keyKendaraan = GlobalKey();

  HomeController({required this.motorProvider, required this.serviceProvider});

  @override
  void onInit() {
    super.onInit();
    // ShowcaseView.register(scope: "tutorial_home");
    // Delay lebih lama untuk memastikan GetConnect sudah fully initialized
    _initDataAndTutorial();
  }

  Future<void> _initDataAndTutorial() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      await fetchMyMotors();
      await fetchServiceList();
    } finally {
      isLoading.value = false;
    }
    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   // 6. Cek status tutorial LOKAL untuk halaman Home saja
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     String? userId = authService.user.value?.id.toString();
    //     String tutorialKey =
    //         userId != null ? 'is_first_home_$userId' : 'is_first_home';

    //     bool isFirstTime = box.read(tutorialKey) ?? true;

    //     if (isFirstTime) {
    //       // Tembak showcase-nya
    //       ShowcaseView.getNamed('tutorial_home').startShowCase([
    //         keyProfile,
    //         keyTambahMotor,
    //         keyLayanan,
    //         keyRefresh,
    //         keyKendaraan,
    //       ]);

    //       // Simpan status bahwa user ini sudah melihatnya
    //       box.write(tutorialKey, false);
    //     }
    //   });
    // });
  }

  // @override
  // void onReady() {
  //   super.onReady();

  //   // 3. Panggil pengecekan memori dari TutorialService
  //   if (Get.find<TutorialService>().shouldShowTutorial('is_first_home_view')) {
  //     // 4. Jalankan Showcase menggunakan getNamed sesuai scope yang didaftarkan
  //     ShowcaseView.getNamed(
  //       'tutorial_home',
  //     ).startShowCase([keyProfile, keyTambahMotor, keyLayanan, keyRefresh, keyKendaraan]);
  //   }
  // }

  Future<void> fetchMyMotors({int retryCount = 0}) async {
    try {
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
    }
  }

  Future<void> fetchServiceList({int retryCount = 0}) async {
    try {
      debugPrint('🔄 Fetching service list... (Attempt ${retryCount + 1})');

      final response = await serviceProvider.fetchServices();

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      // Jika response null (koneksi belum siap), retry
      if (response.statusCode == null && retryCount < 3) {
        debugPrint(
          '⚠️ Connection not ready, retrying in ${500 * (retryCount + 1)}ms...',
        );
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return fetchServiceList(retryCount: retryCount + 1);
      }

      if (response.isOk && response.body != null) {
        final serviceResponse = ServiceResponse.fromJson(response.body);
        service.value = serviceResponse.data;
        debugPrint('✅ Successfully loaded ${service.length} services');
      } else {
        debugPrint('❌ Response not OK or body null');
        CustomSnackbar.error(
          "Error",
          response.body?['message'] ?? 'Gagal mengambil data layanan',
        );
      }
    } catch (e, stackTrace) {
      // Retry jika exception dan belum 3x
      if (retryCount < 3) {
        debugPrint('⚠️ Exception, retrying... Error: $e');
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return fetchServiceList(retryCount: retryCount + 1);
      }
      debugPrint('❌ Exception in fetchServiceList: $e');
      debugPrint('Stack trace: $stackTrace');
      CustomSnackbar.error("Error", 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  void moveToAddMotor() {
    Get.toNamed('/add-motor');
  }

  void moveToNotifications() {
    Get.toNamed('/notification');
  }

  // void moveToBooking(MotorModel motor) {
  //   Get.toNamed('/booking', arguments: motor.id);
  // }

  // @override
  // void onClose() {
  //   // 5. Unregister saat controller mati agar memori RAM lega kembali
  //   ShowcaseView.getNamed('tutorial_home').unregister();
  //   super.onClose();
  // }
}
