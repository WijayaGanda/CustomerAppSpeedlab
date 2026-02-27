import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';

import '../controllers/add_motor_controller.dart';

class AddMotorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMotorController>(() => AddMotorController());
    Get.lazyPut<MotorcyclesProvider>(() => MotorcyclesProvider());
  }
}
