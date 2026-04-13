import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Login ",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              title: "Selamat Datang",
              subtitle: "Silakan masuk untuk melanjutkan",
              icon: Image.asset(
                "assets/images/logo_spl.jpeg",
                width: 70,
                height: 70,
              ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.transparent),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      // iconLabel: Icons.abc,
                      controller: controller.emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      hintText: "Masukkan email anda",
                      isObscure: false,
                    ),
                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        labelText: 'Password',
                        // keyboardType: TextInputType.pass,
                        prefixIcon: Icons.key,
                        maxLines: 1,
                        hintText: "Masukkan password anda",
                        isObscure: controller.isVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.togglePasswordVisibility();
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/forgot-password');
                        },
                        child: Text(
                          "Lupa Password?",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () =>
                          controller.isLoading.value
                              ? CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                              )
                              : CustomButton(
                                icon: Icons.door_front_door_outlined,
                                text: "Masuk",
                                onPressed: () {
                                  controller.login();
                                },
                                backgroundColor: Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                              ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "ATAU",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    IconButton(
                      onPressed: () {
                        controller.loginWithGoogle();
                      },
                      icon: Image.network(
                        "https://www.gstatic.com/marketing-cms/assets/images/d5/dc/cfe9ce8b4425b410b49b7f2dd3f3/g.webp=s96-fcrop64=1,00000000ffffffff-rw",
                        width: 22,
                        height: 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(15),
                        elevation: 4,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum Punya Akun?", style: GoogleFonts.poppins()),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/register');
                          },
                          child: Text("Daftar", style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
