import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/edit_motor_controller.dart';

class EditMotorView extends GetView<EditMotorController> {
  const EditMotorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Edit Motor",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        final motor = controller.motor.value;
        if (motor == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              CustomHeader(
                title: "Ubah Data Motor",
                subtitle: "Perbarui informasi motor Anda",
                icon: Icons.edit,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CustomTextField(
                      prefixIcon: Icons.person,
                      controller: controller.brandCtrl,
                      labelText: "Merek",
                      isObscure: false,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.email,
                      controller: controller.modelCtrl,
                      labelText: "Model",
                      iconLabel: Icons.abc,
                      isObscure: false,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.phone,
                      controller: controller.yearCtrl,
                      labelText: "Tahun",
                      isObscure: false,
                      iconLabel: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.location_city,
                      controller: controller.licensePlateCtrl,
                      labelText: "Plat Nomor",
                      isObscure: false,
                      iconLabel: Icons.home,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.location_city,
                      controller: controller.colorCtrl,
                      labelText: "Warna",
                      isObscure: false,
                      iconLabel: Icons.color_lens,
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
                                onPressed:
                                    () => controller.updateMotor(
                                      motor.id.toString(),
                                    ),
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
        );
      }),
    );
  }
}
