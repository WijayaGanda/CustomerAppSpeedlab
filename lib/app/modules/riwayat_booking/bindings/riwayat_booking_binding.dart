import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';

import '../controllers/riwayat_booking_controller.dart';

class RiwayatBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatBookingController>(
      () => RiwayatBookingController(provider: Get.find<BookingsProvider>()),
    );
  }
}
