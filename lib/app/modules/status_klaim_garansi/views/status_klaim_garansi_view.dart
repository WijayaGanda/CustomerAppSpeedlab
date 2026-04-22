import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/info_card.dart';

import '../controllers/status_klaim_garansi_controller.dart';

class StatusKlaimGaransiView extends GetView<StatusKlaimGaransiController> {
  const StatusKlaimGaransiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Status Klaim Garansi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (controller.selectedBooking.value != null) {
                controller.fetchWarrantyClaims();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.serviceHistory.isEmpty) {
          return const Center(child: Text('Tidak ada data riwayat servis'));
        }

        if (controller.warrantyClaims.isEmpty) {
          return const Center(child: Text('Belum ada klaim garansi'));
        }

        final serviceHistory = controller.serviceHistory.first;
        final warrantyClaims = controller.warrantyClaims;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: ColorTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorTheme.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.motorcycle,
                        size: 40,
                        color: ColorTheme.darkBgPrimary,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kendaraan Anda:",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              serviceHistory.motorcycleId!['licensePlate'] ??
                                  "Tidak Diketahui",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Garansi berlaku hingga: ${serviceHistory.warrantyExpiry != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(serviceHistory.warrantyExpiry!.toIso8601String())) : "Tidak Diketahui"}",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                      color: Colors.black.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status Klaim Garansi",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                warrantyClaims.first.status ?? "-",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: Color(0xFFF4F6F9),
                            thickness: 1.5,
                          ),
                        ),
                        InfoRow(
                          icon: Icons.comment,
                          label: "Keluhan",
                          value: warrantyClaims.first.complaint,
                        ),
                        InfoRow(
                          icon: Icons.comment,
                          label: "Alasan Penolakan",
                          value: warrantyClaims.first.rejectionReason ?? "-",
                        ),

                        InfoRow(
                          icon: Icons.date_range,
                          label: "Tanggal Klaim",
                          value:
                              warrantyClaims.first.claimDate != null
                                  ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(warrantyClaims.first.claimDate!)
                                  : "Tidak Diketahui",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
