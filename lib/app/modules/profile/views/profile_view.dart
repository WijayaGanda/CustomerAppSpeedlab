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
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.black, // Mengikuti koridor identitas Hitam
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Profil Saya",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: ColorTheme.primary),
          );
        }
        final user = controller.users.value;

        return RefreshIndicator(
          onRefresh: () => controller.fetchProfile(),
          color: ColorTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              children: [
                // Profile Avatar & Main Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFF4F6F9),
                          backgroundImage:
                              user.avatar != null
                                  ? NetworkImage(user.avatar!)
                                  : null,
                          child:
                              user.avatar == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? "Pengguna",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? "Email tidak tersedia",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Detail Data Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildUserInfoRow(
                        Icons.phone_android_rounded,
                        "No. Telepon",
                        user.phone,
                      ),
                      const Divider(
                        height: 24,
                        color: Color(0xFFF4F6F9),
                        thickness: 1.5,
                      ),
                      _buildUserInfoRow(
                        Icons.home_work_rounded,
                        "Alamat",
                        user.address,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Menu
                _buildMenuItem(
                  icon: Icons.edit_rounded,
                  label: "Edit Profil",
                  subtitle: "Perbarui informasi pribadi Anda",
                  onTap: () {
                    controller.editProfile();
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_rounded,
                  label: "Keamanan",
                  subtitle: "Ubah kata sandi dan proteksi akun",
                  onTap: () {
                    Get.toNamed('/security');
                  },
                ),

                const SizedBox(height: 24),

                // Logout Button
                CustomButton(
                  text: "Keluar Akun",
                  onPressed: () {
                    ConfirmationDialog.show(
                      title: "Konfirmasi Logout",
                      message: "Apakah Anda yakin ingin keluar dari akun ini?",
                      confirmText: "Ya, Keluar",
                      onConfirm: () {
                        controller.logout();
                      },
                    );
                  },
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red[700]!,
                  icon: Icons.logout_rounded,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorTheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ColorTheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value == null || value.isEmpty ? '-' : value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2D3142),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFFF4F6F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isDanger ? Colors.red : const Color(0xFF2D3142),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              isDanger ? Colors.red : const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[300],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
