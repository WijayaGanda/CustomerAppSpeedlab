import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';

import '../controllers/email_page_controller.dart';

class EmailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailPageController>(
      () => EmailPageController(provider: Get.find<AuthProvider>()),
    );
  }
}
