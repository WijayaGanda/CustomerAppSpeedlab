import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/info_card.dart';
import '../controllers/detail_motor_controller.dart';

class DetailMotorView extends GetView<DetailMotorController> {
  const DetailMotorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Koridor light background
      appBar: AppBar(
        title: Text(
          'Detail Motor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.black, // Koridor identitas hitam
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Motor info card
            Obx(() {
              final motor = controller.detailMotor.value;
              if (motor == null) {
                return Center(
                    child: CircularProgressIndicator(color: ColorTheme.neonYellow));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Motor info container
                    Container(
                      width: double.infinity,
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
                        border: Border.all(
                            color: Colors.black.withOpacity(0.05), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Motor icon with background
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.two_wheeler_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Color(0xFFF4F6F9), thickness: 1.5),
                            const SizedBox(height: 20),

                            // Motor details
                            InfoRow(
                              icon: Icons.sell_rounded,
                              label: "Brand",
                              value: motor.brand,
                              iconColor: Colors.black87,
                            ),
                            InfoRow(
                              icon: Icons.directions_bike_rounded,
                              label: "Model",
                              value: motor.model,
                              iconColor: Colors.black87,
                            ),
                            InfoRow(
                              icon: Icons.calendar_month_rounded,
                              label: "Tahun",
                              value: motor.year.toString(),
                              iconColor: Colors.black87,
                            ),
                            InfoRow(
                              icon: Icons.pin_rounded,
                              label: "No. Polisi",
                              value: motor.licensePlate,
                              iconColor: Colors.black87,
                            ),
                            InfoRow(
                              icon: Icons.palette_rounded,
                              label: "Warna",
                              value: motor.color,
                              iconColor: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit_rounded,
                            label: "Edit",
                            backgroundColor: ColorTheme.neonYellow,
                            foregroundColor: Colors.black,
                            onPressed: () {
                              Get.toNamed('/edit-motor', arguments: motor);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete_rounded,
                            label: "Hapus",
                            backgroundColor: Colors.red.withOpacity(0.1),
                            foregroundColor: Colors.red[600]!,
                            onPressed: () {
                              ConfirmationDialog.show(
                                title: "Hapus Motor",
                                message:
                                    "Apakah Anda yakin ingin menghapus data motor ini?",
                                confirmText: "Ya, Hapus",
                                confirmColor: Colors.red[600]!,
                                onConfirm: () {
                                  controller.deleteMotor(motor.id.toString());
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
