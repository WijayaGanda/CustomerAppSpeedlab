import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
// import 'package:speedlab_pelanggan/app/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Put providers first dengan Get.put agar langsung di-initialize
    Get.put<ProfileProvider>(ProfileProvider());
    Get.put<MotorcyclesProvider>(MotorcyclesProvider());

    // Then controllers with dependency injection
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(
      () => HomeController(motorProvider: Get.find<MotorcyclesProvider>()),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(provider: Get.find<ProfileProvider>()),
    );
    // Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
