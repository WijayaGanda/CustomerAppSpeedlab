import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';

import '../controllers/status_klaim_garansi_controller.dart';

class StatusKlaimGaransiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatusKlaimGaransiController>(
      () => StatusKlaimGaransiController(
        provider: Get.find<ServiceHistoryProvider>(),
        warrantyProvider: Get.find<WarrantyClaimProvider>(),
      ),
    );
  }
}
