import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';

import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(
      () => NotificationController(provider: Get.find<NotifProvider>()),
    );
  }
}
