import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
// import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class EditProfileController extends GetxController {
  final provider = Get.find<ProfileProvider>();
  final authService = Get.find<AuthService>();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.arguments;
    nameCtrl = TextEditingController(text: user.name ?? '');
    emailCtrl = TextEditingController(text: user.email ?? '');
    phoneCtrl = TextEditingController(text: user.phone ?? '');
    addressCtrl = TextEditingController(text: user.address ?? '');
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      if (nameCtrl.text.isEmpty ||
          emailCtrl.text.isEmpty ||
          phoneCtrl.text.isEmpty ||
          addressCtrl.text.isEmpty) {
        CustomSnackbar.error("Oops", "Semua field harus diisi!");
        return;
      }

      final response = await provider.updateProfile({
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneCtrl.text,
        'address': addressCtrl.text,
      });
      if (response.isOk && response.body != null) {
        if (Get.isRegistered<ProfileController>()) {
          final profileC = Get.find<ProfileController>();
          profileC.users.update((val) {
            val?.name = nameCtrl.text;
            val?.email = emailCtrl.text;
            val?.phone = phoneCtrl.text;
            val?.address = addressCtrl.text;
          });
          CustomSnackbar.success("Sukses", "Profil berhasil diperbarui");
          Get.offAllNamed('/dashboard');
        }
      } else {
        CustomSnackbar.error(
          "Error",
          response.body['message'] ?? "Gagal memperbarui profil",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    nameCtrl.text = '';
    emailCtrl.text = '';
    phoneCtrl.text = '';
    addressCtrl.text = '';
  }
}
