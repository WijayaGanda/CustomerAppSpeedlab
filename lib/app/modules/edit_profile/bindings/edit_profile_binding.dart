import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
// import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
    Get.lazyPut<ProfileController>(
      () => ProfileController(provider: Get.find<ProfileProvider>()),
    );
    Get.lazyPut<ProfileProvider>(() => ProfileProvider());
    // Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
