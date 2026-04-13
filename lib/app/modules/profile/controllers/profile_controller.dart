import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

class ProfileController extends GetxController {
  final authservice = Get.find<AuthService>();
  final ProfileProvider provider;
  ProfileController({required this.provider});

  var users = UserModel().obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit(); 
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchProfile();
      if (response.isOk && response.body != null) {
        users.value = UserModel.fromJson(response.body['data']);
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Gagal mengambil data profil',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void editProfile() {
    Get.toNamed('/edit-profile', arguments: users.value);
  }

  void logout() {
    authservice.logout();
    Get.offAllNamed('/login');
  }
}
