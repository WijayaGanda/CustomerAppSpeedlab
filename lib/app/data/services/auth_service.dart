import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

class AuthService extends GetxService {
  final box = GetStorage();

  var user = Rxn<UserModel>();

  bool get isLoggedIn => box.hasData("token");
  String? get token => box.read("token");

  @override
  void onInit() {
    super.onInit();
    // Auto-load data saat aplikasi dibuka
    if (box.hasData("user")) {
      final userData = box.read("user");
      // Convert dari Map json ke Object Model
      user.value = UserModel.fromJson(userData);
    }
  }

  void login(String token, UserModel userModel) {
    box.write("token", token);
    box.write("user", userModel.toJson()); // Simpan user ke storage
    user.value = userModel; // Update state global
  }

  void logout() {
    box.remove("token");
    box.remove("user");
    user.value = null; // Clear state global
  }
}
