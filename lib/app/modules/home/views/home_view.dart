import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
// import 'package:speedlab_pelanggan/app/utils/widget/custom_header.dart';
// import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
// import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat Datang,",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Obx(
              () => Text(
                controller.authService.user.value?.name ?? "User",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                controller.dashC.changePage(1); // Ganti ke halaman Profil
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    Image.network(
                      controller.authService.user.value?.avatar ??
                          "https://ui-avatars.com/api/?name=${controller.authService.user.value?.name ?? 'User'}&background=4CAF50&color=fff",
                    ).image,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section dengan Gradient
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorTheme.primary, ColorTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Menu Utama",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMenuCard(
                            icon: Icons.add_circle_outline,
                            label: "Tambah\nMotor",
                            color: Colors.blue,
                            onTap: controller.moveToAddMotor,
                          ),
                          _buildMenuCard(
                            icon: Icons.build_circle_outlined,
                            label: "Layanan\nServis",
                            color: Colors.orange,
                            onTap: () {
                              // TODO: Navigasi ke halaman layanan
                              Get.snackbar(
                                "Info",
                                "Fitur layanan akan segera hadir",
                                backgroundColor: Colors.orange[100],
                                colorText: Colors.black87,
                              );
                            },
                          ),
                          _buildMenuCard(
                            icon: Icons.refresh_rounded,
                            label: "Refresh\nData",
                            color: Colors.green,
                            onTap: controller.fetchMyMotors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Layanan Servis Section
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Layanan Servis",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Lihat Semua",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    spacing: 10, // Jarak antar card
                    children: [
                      _buildMenuCard(
                        icon: Icons.engineering,
                        label: "Engineering",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.engineering,
                        label: "Engineering",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.engineering,
                        label: "Engineering",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.engineering,
                        label: "Engineering",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.engineering,
                        label: "Engineering",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // List Motor Section Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Motor Saya",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${controller.motors.length} Motor",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 10),
              controller.motors.isEmpty
                  ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.motorcycle, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada motor terdaftar\nTambahkan motor untuk melakukan booking",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: controller.moveToAddMotor,
                          icon: Icon(Icons.add),
                          label: Text("Tambah Motor"),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    itemCount:
                        controller.motors.length >= 2
                            ? 2
                            : controller.motors.length,
                    itemBuilder: (context, index) {
                      final motor = controller.motors[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue[100],
                                    child: Icon(
                                      Icons.motorcycle,
                                      color: Colors.blue[700],
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${motor.brand} ${motor.model}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          motor.licensePlate ??
                                              "No License Plate",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "${motor.year}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.palette,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              motor.color ?? "No Color",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Get.toNamed(
                                          '/motor-detail',
                                          arguments: motor,
                                        );
                                      },
                                      icon: Icon(Icons.info_outline, size: 18),
                                      label: Text(
                                        "Lihat Detail",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue[700],
                                        side: BorderSide(
                                          color: Colors.blue[700]!,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed(
                                          '/booking',
                                          arguments: motor,
                                        );
                                      },
                                      icon: Icon(
                                        Icons.calendar_month,
                                        size: 18,
                                      ),
                                      label: Text(
                                        "Booking",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorTheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
