import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Register  ",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              title: "Silahkan Mendaftar",
              subtitle: "Masukkan Data dengan benar",
              icon: Image.asset(
                "assets/images/logo_spl.jpeg",
                width: 70,
                height: 70,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomTextField(
                    controller: controller.nameCtrl,
                    labelText: "Nama",
                    hintText: "Masukkan nama anda",
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.name,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.emailCtrl,
                    labelText: "Email",
                    hintText: "Masukkan email anda",
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    iconLabel: Icons.abc,
                    isObscure: false,
                  ),
                  Obx(
                    () => CustomTextField(
                      controller: controller.passwordCtrl,
                      labelText: "Password",
                      isObscure: controller.isVisible.value,
                      hintText: "Masukkan password anda",
                      iconLabel: Icons.key,
                      maxLines: 1,
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.togglePasswordVisibility();
                        },
                        icon: Icon(
                          controller.isVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      // obscureText: true,
                    ),
                  ),
                  CustomTextField(
                    controller: controller.phoneCtrl,
                    labelText: "Phone",
                    hintText: "Masukkan nomor telepon anda",
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    iconLabel: Icons.numbers,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.addressCtrl,
                    labelText: "Address",
                    hintText: "Masukkan alamat anda",
                    prefixIcon: Icons.home,
                    iconLabel: Icons.location_city,
                    isObscure: false,
                  ),
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                              color: Color(0xFFFFD700),
                            )
                            : CustomButton(
                              icon: Icons.app_registration,
                              text: "Daftar",
                              onPressed: () {
                                controller.register();
                              },
                              backgroundColor: Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
