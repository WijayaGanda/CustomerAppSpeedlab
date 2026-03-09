import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
// import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
import 'package:speedlab_pelanggan/app/utils/widget/info_card.dart';
import '../controllers/detail_motor_controller.dart';

class DetailMotorView extends GetView<DetailMotorController> {
  const DetailMotorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detail Motor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorTheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Motor info card
            Obx(() {
              final motor = controller.detailMotor.value;
              if (motor == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Motor info container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: ColorTheme.primary, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Motor icon with background
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorTheme.primary.withOpacity(0.2),
                                    ColorTheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.motorcycle,
                                color: ColorTheme.primary,
                                size: 40,
                              ),
                            ),
                            Divider(),
                            const SizedBox(height: 20),

                            // Motor details
                            InfoRow(
                              icon: Icons.directions_car,
                              label: "Brand",
                              value: motor.brand,
                            ),
                            InfoRow(
                              icon: Icons.model_training,
                              label: "Model",
                              value: motor.model,
                            ),
                            InfoRow(
                              icon: Icons.calendar_today,
                              label: "Tahun",
                              value: motor.year.toString(),
                            ),
                            InfoRow(
                              icon: Icons.confirmation_number,
                              label: "No. Polisi",
                              value: motor.licensePlate,
                            ),
                            InfoRow(
                              icon: Icons.palette,
                              label: "Warna",
                              value: motor.color,
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
                            icon: Icons.edit,
                            label: "Edit Motor",
                            color: Colors.blue,
                            onPressed: () {
                              Get.toNamed('/edit-motor', arguments: motor);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete,
                            label: "Hapus Motor",
                            color: Colors.red,
                            onPressed: () {
                              ConfirmationDialog.show(
                                title: "Konfirmasi",
                                message:
                                    "Apakah Anda yakin ingin menghapus data motor ini?",
                                confirmText: "Hapus",
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
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
