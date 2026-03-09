import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/info_card.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Halaman Profil ",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: ColorTheme.primary,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final user = controller.users.value;

        return RefreshIndicator(
          onRefresh: () => controller.fetchProfile(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorTheme.primary, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  user.avatar != null
                                      ? NetworkImage(user.avatar!)
                                      : null,
                            ),
                            Divider(color: Colors.black, height: 30),
                            SizedBox(height: 10),
                            _buildUserInfoRow(Icons.person, "Nama", user.name),
                            SizedBox(height: 10),
                            _buildUserInfoRow(Icons.email, "Email", user.email),
                            SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.phone,
                              "No. Telepon",
                              user.phone,
                            ),
                            SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.home,
                              "Alamat",
                              user.address,
                            ),
                            Divider(color: Colors.black, height: 30),
                            CustomButton(
                              text: "Logout",
                              onPressed: () {
                                ConfirmationDialog.show(
                                  title: "Konfirmasi Logout",
                                  message: "Apakah Anda yakin ingin logout?",
                                  onConfirm: () {
                                    controller.logout();
                                  },
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.door_back_door,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildmenuItem(
                    icon: Icons.edit,
                    label: "Edit Profil",
                    subtitle: "Ubah informasi profil Anda",
                    onTap: () {
                      controller.editProfile();
                    },
                  ),
                  SizedBox(height: 10),
                  _buildmenuItem(
                    icon: Icons.security_rounded,
                    label: "Keamanan",
                    subtitle: "Ubah password dan keamanan",
                    onTap: () {
                      Get.toNamed('/security');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

Widget _buildUserInfoRow(IconData icon, String label, String? value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.black),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              value ?? '-',
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildmenuItem({
  required IconData icon,
  required String label,
  required String subtitle,
  required VoidCallback onTap,
  bool isDanger = false,
  bool showArrow = true,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: ColorTheme.primary, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isDanger
                        ? Colors.red.withValues(alpha: 0.1)
                        : ColorTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.red : ColorTheme.primary,

                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    ),
  );
}
