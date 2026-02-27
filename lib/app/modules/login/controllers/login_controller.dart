import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class LoginController extends GetxController {
  final AuthProvider provider;
  LoginController({required this.provider});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        "220972392486-kf83vi2vioc9n89nps3p2evdire1rotn.apps.googleusercontent.com",
  );
  var isLoading = false.obs;
  var isVisible = true.obs;

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      CustomSnackbar.error("Opps", "Email Dan Password harus diisi");
      return;
    }

    isLoading.value = true;
    try {
      final response = await provider.login(
        emailController.text,
        passwordController.text,
      );

      if (response.isOk && response.body != null) {
        final loginres = LoginResponseModel.fromJson(response.body['data']);
        debugPrint('Login response: ${response.body}');
        if (loginres.token != null) {
          Get.find<AuthService>().login(loginres.token!, loginres.user!);
          debugPrint("token disimpan");
          CustomSnackbar.success(
            "haloo",
            "Selamat Datang ${loginres.user?.name ?? 'User'}",
          );
          Get.offAllNamed('/dashboard', arguments: loginres.user);
          debugPrint('Login successful, token: ${loginres.token}');
        }
      } else {
        // Tampilkan pesan error spesifik jika ada dari server
        String messsage =
            response.body?['message'] ??
            "Gagal Login, Cek kembali email dan password";
        CustomSnackbar.error("Error", messsage);
      }
    } catch (e) {
      debugPrint("Exception occurs: $e"); // Debugging error coding/parsing
      CustomSnackbar.error("Error", "Terjadi kesalahan sistem: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Sign out dulu untuk memastikan popup muncul
      await _googleSignIn.signOut();

      debugPrint("=== Memulai Google Sign-In ===");

      // Memicu popup login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      debugPrint("Google User: ${googleUser?.email}");

      if (googleUser == null) {
        debugPrint("User membatalkan login atau terjadi error");
        isLoading.value = false;
        return; // User membatalkan login
      }

      debugPrint("Mendapatkan authentication credentials...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      debugPrint("ID Token: ${idToken != null ? 'Ada ✓' : 'Null ✗'}");
      debugPrint(
        "Access Token: ${googleAuth.accessToken != null ? 'Ada ✓' : 'Null ✗'}",
      );

      if (idToken != null) {
        debugPrint("Mengirim idToken ke backend...");
        final response = await provider.loginWithGoogle(idToken);
        if (response.isOk) {
          final loginres = LoginResponseModel.fromJson(response.body['data']);
          if (loginres.token != null) {
            Get.find<AuthService>().login(loginres.token!, loginres.user!);
            CustomSnackbar.success(
              "haloo",
              "Selamat Datang ${loginres.user?.name ?? 'User'}",
            );
            Get.offAllNamed('/dashboard', arguments: loginres.user);
          }
        } else {
          debugPrint("Backend response error: ${response.statusCode}");
          debugPrint("Backend body: ${response.body}");
          String messsage =
              response.body?['message'] ?? "Gagal Login dengan Google";
          CustomSnackbar.error("Error", messsage);
        }
      } else {
        debugPrint("⚠️ ID Token adalah NULL - Konfigurasi OAuth bermasalah!");
        CustomSnackbar.error(
          "Error",
          "ID Token tidak ditemukan. Periksa konfigurasi Google Cloud Console.",
        );
      }
    } catch (e) {
      debugPrint("=== Google Sign-In Error ===");
      debugPrint("Error Type: ${e.runtimeType}");
      debugPrint("Error Message: $e");
      CustomSnackbar.error("Error", "Gagal login dengan Google: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
