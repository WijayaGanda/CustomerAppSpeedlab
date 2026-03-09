import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';

import '../controllers/detail_motor_controller.dart';

class DetailMotorBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingsProvider());
    Get.put(MotorcyclesProvider());
    Get.lazyPut<DetailMotorController>(
      () => DetailMotorController(
        bookingsProvider: Get.find<BookingsProvider>(),
        motorcyclesProvider: Get.find<MotorcyclesProvider>(),
      ),
    );
  }
}
