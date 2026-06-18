import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';

import '../controllers/otp_page_controller.dart';

class OtpPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpPageController>(
      () => OtpPageController(provider: Get.find<AuthProvider>()),
    );
  }
}
