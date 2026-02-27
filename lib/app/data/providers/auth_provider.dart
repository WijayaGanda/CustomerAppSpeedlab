import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class AuthProvider extends ApiService {
  Future<Response> login(String email, String password) {
    return post('api/auth/login', {'email': email, 'password': password});
  }

  Future<Response> register(Map<String, dynamic> data) {
    return post('api/auth/register', data);
  }

  Future<Response> loginWithGoogle(String idToken) {
    return post("api/auth/google", {'token': idToken});
  }
}
