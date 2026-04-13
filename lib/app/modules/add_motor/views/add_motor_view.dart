import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/add_motor_controller.dart';

class AddMotorView extends GetView<AddMotorController> {
  const AddMotorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Motor Baru',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              icon: Icon(
                Icons.motorcycle,
                color: ColorTheme.neonYellow,
                // color: ColorTheme.secondaryColor,
                // size: 28,
              ),
              title: "Tambahkan Motor",
              subtitle: "Daftarkan motor kamu untuk memudahkan proses booking!",
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomTextField(
                    controller: controller.brand,
                    labelText: "Merek Motor",
                    prefixIcon: Icons.motorcycle,
                    iconLabel: Icons.branding_watermark,
                    isObscure: false,
                    hintText: "Contoh: Honda, Yamaha, Suzuki",
                  ),
                  CustomTextField(
                    controller: controller.model,
                    labelText: "Model Motor",
                    prefixIcon: Icons.motorcycle,
                    iconLabel: Icons.model_training,
                    isObscure: false,
                    hintText: "Contoh: CBR, Vario, Nmax",
                  ),
                  CustomTextField(
                    controller: controller.year,
                    labelText: "Tahun Motor",
                    prefixIcon: Icons.motorcycle,
                    iconLabel: Icons.calendar_today,
                    isObscure: false,
                    hintText: "Contoh: 2020, 2021, 2022",
                  ),
                  CustomTextField(
                    controller: controller.licensePlate,
                    labelText: "Plat Nomor",
                    prefixIcon: Icons.motorcycle,
                    iconLabel: Icons.numbers,
                    isObscure: false,
                    hintText: "Contoh: B 1234 AB",
                  ),
                  CustomTextField(
                    controller: controller.color,
                    labelText: "Warna Motor",
                    prefixIcon: Icons.motorcycle,
                    iconLabel: Icons.color_lens,
                    isObscure: false,
                    hintText: "Contoh: Merah, Biru, Hitam",
                  ),
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? CircularProgressIndicator()
                            : CustomButton(
                              backgroundColor: ColorTheme.secondaryColor,
                              foregroundColor: Colors.black,
                              onPressed: () {
                                controller.addMotor();
                              },
                              icon: Icons.add,
                              text: "Tambah Motor",
                            ),
                  ),
                  SizedBox(height: 12),
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? CircularProgressIndicator()
                            : CustomButton(
                              backgroundColor: Colors.white,
                              foregroundColor: ColorTheme.secondaryColor,
                              onPressed: () {
                                controller.reset();
                              },
                              icon: Icons.refresh,
                              text: "Reset",
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
