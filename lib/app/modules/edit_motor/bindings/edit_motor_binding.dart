import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';

import '../controllers/edit_motor_controller.dart';

class EditMotorBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<MotorcyclesProvider>();
    Get.put<MotorcyclesProvider>(MotorcyclesProvider());
    Get.lazyPut<MotorcyclesProvider>(() => MotorcyclesProvider());
    Get.lazyPut<EditMotorController>(
      () => EditMotorController(provider: Get.find<MotorcyclesProvider>()),
    );
  }
}
