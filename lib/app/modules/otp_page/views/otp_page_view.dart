import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/otp_page_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPageView extends GetView<OtpPageController> {
  const OtpPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halaman OTP',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        foregroundColor: Colors.white,
        // centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 80,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Masukkan Kode Verifikasi",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                                "Kami telah mengirimkan 6 digit kode ke email\n",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: controller.email,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 🔥 MENGATASI OVERFLOW KOTAK OTP 🔥
                        // Bungkus dengan Padding agar tidak menabrak tepi layar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: FittedBox(
                            child: MaterialPinField(
                              length: 6,
                              theme: const MaterialPinTheme(
                                shape: MaterialPinShape.outlined,
                                focusedBorderColor: Colors.blueAccent,
                                // Opsional: Jika masih overflow, tambahkan pengaturan ukuran kotak di sini jika package mendukungnya
                              ),
                              onChanged: (value) {
                                controller.currentText.value = value;
                              },
                              onCompleted: (value) {
                                controller.currentText.value = value;
                                controller.verifyOtp();
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     const Text(
                        //       "Belum menerima kode? ",
                        //       style: TextStyle(color: Colors.black54),
                        //     ),
                        //     GestureDetector(
                        //       onTap: controller.resendOtp,
                        //       child: const Text(
                        //         "Kirim Ulang",
                        //         style: TextStyle(
                        //           color: Colors.blueAccent,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        // Spacer sekarang AMAN digunakan karena dilindungi IntrinsicHeight
                        const Spacer(),
                        const SizedBox(
                          height: 20,
                        ), // Jarak ekstra agar tidak terlalu mepet dengan keyboard
                        // Tombol Verifikasi
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : controller.verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Verifikasi",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Jarak bawah layar
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
