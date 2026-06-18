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

  Future<Response> forgotPassword(Map<String, dynamic> data) {
    return post('api/auth/forgot-password', data);
  }

  Future<Response> verifyOtp(Map<String, dynamic> data) {
    return post('api/auth/verify-otp', data);
  }

  Future<Response> resetPassword(Map<String, dynamic> data) {
    return post('api/auth/reset-password', data);
  }
}
