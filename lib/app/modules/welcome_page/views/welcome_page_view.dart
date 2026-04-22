import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/welcome_page_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/routes/app_pages.dart';

class WelcomePageView extends GetView<WelcomePageController> {
  const WelcomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Get.offAllNamed(Routes.LOGIN),
                child: Obx(() => Text(
                  controller.currentPage.value == 2 ? "" : "Lewati",
                  style: GoogleFonts.poppins(color: Colors.grey),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPage(
                    imageWidget: Image.asset(
                      "assets/images/logo_spl.jpeg",
                      width: 200,
                      height: 200,
                    ),
                    title: "Selamat Datang di Speedlab",
                    description: "Solusi terbaik untuk perawatan motor Anda. Dapatkan pelayanan profesional dengan mudah dan cepat melalui aplikasi Speedlab.",
                  ),
                  _buildPage(
                    icon: Icons.build_circle_outlined,
                    title: "Layanan Bengkel Terpercaya",
                    description: "Kami menyediakan teknisi handal, suku cadang original, dan transparansi proses servis langsung dari genggaman Anda.",
                  ),
                  _buildPage(
                    icon: Icons.speed,
                    title: "Mulai Perjalanan Anda",
                    description: "Bergabunglah sekarang! Nikmati kemudahan reservasi, pantau riwayat servis, dan dapatkan promo menarik.",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Obx(
                        () => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          width: controller.currentPage.value == index ? 24.0 : 8.0,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? const Color(0xFFFFD700)
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => controller.currentPage.value == 2
                        ? Column(
                            children: [
                              CustomButton(
                                text: "Login",
                                icon: Icons.login,
                                onPressed: () => Get.offAllNamed(Routes.LOGIN),
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () => Get.offAllNamed(Routes.REGISTER),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFFFD700)),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "Daftar",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CustomButton(
                            text: "Selanjutnya",
                            icon: Icons.arrow_forward,
                            onPressed: () {
                              controller.pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    IconData? icon,
    Widget? imageWidget,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageWidget != null) imageWidget,
          if (icon != null)
            Icon(
              icon,
              size: 150,
              color: const Color(0xFFFFD700),
            ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
