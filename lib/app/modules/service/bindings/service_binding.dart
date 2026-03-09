import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';

import '../controllers/service_controller.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<ServiceController>(
    //   ServiceController(provider: Get.find<ServiceProvider>()),
    // );
    Get.lazyPut<ServiceController>(
      () => ServiceController(provider: Get.find<ServiceProvider>()),
    );
  }
}
