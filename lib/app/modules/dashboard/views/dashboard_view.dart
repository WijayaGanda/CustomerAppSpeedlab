import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => SalomonBottomBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          backgroundColor: Colors.black,
          curve: Curves.easeInOut,
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Home", style: GoogleFonts.poppins(fontSize: 12)),
              selectedColor: ColorTheme.neonYellow,
              unselectedColor: Colors.white,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.build),
              title: Text(
                "Layanan Servis",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              selectedColor: ColorTheme.neonYellow,
              unselectedColor: Colors.white,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.history),
              title: Text(
                "Riwayat Booking",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              selectedColor: ColorTheme.neonYellow,
              unselectedColor: Colors.white,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text("Profil", style: GoogleFonts.poppins(fontSize: 12)),
              selectedColor: ColorTheme.neonYellow,
              unselectedColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
