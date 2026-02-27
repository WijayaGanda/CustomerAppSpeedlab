import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingsProvider>(() => BookingsProvider());
    Get.lazyPut<ServiceProvider>(() => ServiceProvider());
    Get.lazyPut<BookingController>(
      () => BookingController(
        provider: Get.find<BookingsProvider>(),
        authService: Get.find<AuthService>(),
        serviceProvider: Get.find<ServiceProvider>(),
      ),
    );
  }
}
