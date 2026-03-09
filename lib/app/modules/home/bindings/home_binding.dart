import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    // Gunakan putIfAbsent agar tidak duplikat jika sudah ada
    if (!Get.isRegistered<MotorcyclesProvider>()) {
      Get.put<MotorcyclesProvider>(MotorcyclesProvider());
    }
    if (!Get.isRegistered<ServiceProvider>()) {
      Get.put<ServiceProvider>(ServiceProvider());
    }
    Get.lazyPut<HomeController>(
      () => HomeController(
        motorProvider: Get.find<MotorcyclesProvider>(),
        serviceProvider: Get.find<ServiceProvider>(),
      ),
    );
  }
}
