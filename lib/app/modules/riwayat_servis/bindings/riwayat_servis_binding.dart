import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';

import '../controllers/riwayat_servis_controller.dart';

class RiwayatServisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatServisController>(
      () =>
          RiwayatServisController(provider: Get.find<ServiceHistoryProvider>()),
    );
  }
}
