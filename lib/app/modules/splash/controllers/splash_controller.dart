import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    if (authService.isLoggedIn) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.WELCOME_PAGE);
    }
  }
}
