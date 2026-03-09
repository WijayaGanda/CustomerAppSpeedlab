import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';

class ServiceController extends GetxController {
  final ServiceProvider provider;

  ServiceController({required this.provider});

  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchServices();
      if (response.isOk && response.body != null) {
        final servicesResponse = ServiceResponse.fromJson(response.body);
        services.value = servicesResponse.data;
      } else {
        Get.snackbar('Error', 'Gagal memuat layanan servis');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat layanan servis');
    } finally {
      isLoading.value = false;
    }
  }
}
