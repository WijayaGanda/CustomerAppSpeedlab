import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class ProfileProvider extends ApiService {
  Future<Response> fetchProfile() => get("api/auth/profile");

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      put("api/auth/profile", data);
}
