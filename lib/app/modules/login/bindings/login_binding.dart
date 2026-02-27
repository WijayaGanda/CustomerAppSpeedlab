import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(provider: Get.find<AuthProvider>()),
    );
    Get.lazyPut<AuthProvider>(() => AuthProvider());
  }
}
