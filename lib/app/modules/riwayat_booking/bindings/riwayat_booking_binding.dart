import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/modules/payment_webview/controllers/payment_webview_controller.dart';

import '../controllers/riwayat_booking_controller.dart';

class RiwayatBookingBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(PaymentWebviewController());
    Get.lazyPut<RiwayatBookingController>(
      () => RiwayatBookingController(
        provider: Get.find<BookingsProvider>(),
        paymentProvider: Get.find<PaymentProvider>(),
        serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
      ),
    );
  }
}
