import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Edit Profil",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              title: "Ubah Data Profil",
              subtitle: "Perbarui informasi profil Anda",
              icon: Icons.edit,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomTextField(
                    prefixIcon: Icons.person,
                    controller: controller.nameCtrl,
                    labelText: "Nama",
                    isObscure: false,
                  ),
                  CustomTextField(
                    prefixIcon: Icons.email,
                    controller: controller.emailCtrl,
                    labelText: "Email",
                    iconLabel: Icons.abc,
                    isObscure: false,
                  ),
                  CustomTextField(
                    prefixIcon: Icons.phone,
                    controller: controller.phoneCtrl,
                    labelText: "No. Telepon",
                    isObscure: false,
                    iconLabel: Icons.numbers,
                    keyboardType: TextInputType.phone,
                  ),
                  CustomTextField(
                    prefixIcon: Icons.location_city,
                    controller: controller.addressCtrl,
                    labelText: "Alamat",
                    isObscure: false,
                    iconLabel: Icons.home,
                  ),
                  SizedBox(height: 14),
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                              color: ColorTheme.secondaryColor,
                            )
                            : CustomButton(
                              text: "Simpan Perubahan",
                              onPressed: controller.updateProfile,
                              backgroundColor: ColorTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              icon: Icons.save,
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
