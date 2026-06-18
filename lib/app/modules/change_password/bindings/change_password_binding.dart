import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(provider: Get.find<AuthProvider>()),
    );
  }
}
