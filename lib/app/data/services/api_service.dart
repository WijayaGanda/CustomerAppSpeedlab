import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/routes/app_pages.dart';
// import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    // PENTING: Panggil super.onInit() DULU agar httpClient siap
    super.onInit();

    httpClient.baseUrl = 'https://backend-speedlab.vercel.app/';
    httpClient.timeout = const Duration(seconds: 30);

    // Request Interceptor - Tambahkan token ke header
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    // Response Interceptor - Tangani token kadaluarsa
    httpClient.addResponseModifier((request, response) {
      // Jika status 401 (Unauthorized) = token kadaluarsa atau tidak valid
      if (response.statusCode == 401) {
        // Logout user dan hapus data
        final authService = Get.find<AuthService>();
        authService.logout();

        // Redirect ke login
        Get.offAllNamed(Routes.LOGIN);
      }
      return response;
    });
  }
}
