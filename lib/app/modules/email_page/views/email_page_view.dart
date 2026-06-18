import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/email_page_controller.dart';

class EmailPageView extends GetView<EmailPageController> {
  const EmailPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Masukkan Email',
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
                  CustomTextField(
                    // iconLabel: Icons.abc,
                    controller: controller.emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    hintText: "Masukkan email anda",
                    isObscure: false,
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
                              text: "Kirim Kode Reset",
                              onPressed: () {
                                controller.sendResetCode();
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
