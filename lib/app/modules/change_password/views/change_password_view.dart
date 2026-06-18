import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Password Anda',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        foregroundColor: Colors.white,
        // centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
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
                  Obx(
                    () => CustomTextField(
                      controller: controller.newPasswordController,
                      labelText: 'Password Baru',
                      // keyboardType: TextInputType.pass,
                      prefixIcon: Icons.key,
                      maxLines: 1,
                      hintText: "Masukkan password baru anda",
                      isObscure: controller.isVisibleNewPassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isVisibleNewPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.toggleNewPasswordVisibility();
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => CustomTextField(
                      controller: controller.confirmPasswordController,
                      labelText: 'Konfirmasi Password Baru',
                      // keyboardType: TextInputType.pass,
                      prefixIcon: Icons.key,
                      maxLines: 1,
                      hintText: "Konfirmasi password baru anda",
                      isObscure: controller.isVisibleConfirmPassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isVisibleConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.toggleConfirmPasswordVisibility();
                        },
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
                              text: "Ubah Password",
                              onPressed: () {
                                controller.changePassword();
                              },
                              backgroundColor: Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
