import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(provider: Get.find<ProfileProvider>()),
    );
  }
}
