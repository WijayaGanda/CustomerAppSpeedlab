import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
// import 'package:speedlab_pelanggan/app/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_servis/controllers/riwayat_servis_controller.dart';
import 'package:speedlab_pelanggan/app/modules/service/controllers/service_controller.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Put providers first dengan Get.put agar langsung di-initialize
    Get.put<ProfileProvider>(ProfileProvider());
    Get.put<MotorcyclesProvider>(MotorcyclesProvider());
    Get.put<ServiceProvider>(ServiceProvider());
    Get.put<BookingsProvider>(BookingsProvider());
    Get.put<PaymentProvider>(PaymentProvider());
    Get.put<ServiceHistoryProvider>(ServiceHistoryProvider());
    Get.put<WarrantyClaimProvider>(WarrantyClaimProvider());

    // Then controllers with dependency injection
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(
      () => HomeController(
        motorProvider: Get.find<MotorcyclesProvider>(),
        serviceProvider: Get.find<ServiceProvider>(),
      ),
    );
    Get.lazyPut<ServiceController>(
      () => ServiceController(provider: Get.find<ServiceProvider>()),
    );
    Get.lazyPut<RiwayatBookingController>(
      () => RiwayatBookingController(
        provider: Get.find<BookingsProvider>(),
        paymentProvider: Get.find<PaymentProvider>(),
        serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(provider: Get.find<ProfileProvider>()),
    );
    Get.lazyPut<RiwayatServisController>(
      () =>
          RiwayatServisController(provider: Get.find<ServiceHistoryProvider>()),
    );
    // Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
