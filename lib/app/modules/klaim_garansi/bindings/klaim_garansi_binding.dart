import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';

import '../controllers/klaim_garansi_controller.dart';

class KlaimGaransiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KlaimGaransiController>(
      () => KlaimGaransiController(
        provider: Get.find<ServiceHistoryProvider>(),
        warrantyProvider: Get.find<WarrantyClaimProvider>(),
      ),
    );
  }
}
