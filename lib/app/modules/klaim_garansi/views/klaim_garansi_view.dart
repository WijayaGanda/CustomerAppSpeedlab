import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/klaim_garansi_controller.dart';

class KlaimGaransiView extends GetView<KlaimGaransiController> {
  const KlaimGaransiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Klaim Garansi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.serviceHistory.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data riwayat servis'),
                  );
                }

                final serviceHistory = controller.serviceHistory.first;
                return Container(
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
                );
              }),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: 'Keluhan Anda',
                prefixIcon: Icons.report_problem,
                suffixIcon: null,
                isObscure: false,
                controller: controller.complaintController,
                label: 'Keluhan Anda',
                hintText: 'Jelaskan keluhan Anda secara detail',
                maxLines: 5,
                enabled: !controller.hasExistingClaim,
              ),
              Obx(() {
                if (controller.serviceHistory.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Jika sudah ada klaim garansi
                if (controller.hasExistingClaim) {
                  final claim = controller.warrantyClaims.firstWhere(
                    (c) =>
                        c.serviceHistoryId?['_id'] ==
                            controller.serviceHistory.first.id ||
                        c.serviceHistoryId ==
                            controller.serviceHistory.first.id,
                  );

                  return Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.blue),
                            const SizedBox(width: 12),
                            Text(
                              'Klaim Garansi Sudah Diajukan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Anda telah mengajukan klaim garansi untuk layanan ini. Anda tidak dapat mengajukan klaim garansi lagi.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (claim.complaint != null &&
                            claim.complaint!.isNotEmpty) ...[
                          Text(
                            'Keluhan Anda:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            claim.complaint!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        if (claim.status != null &&
                            claim.status!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  claim.status!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Jika garansi sudah kadaluarsa
                return DateTime.now().isAfter(
                      controller.serviceHistory.first.warrantyExpiry!,
                    )
                    ? Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Garansi sudah kadaluarsa. Anda tidak dapat mengajukan klaim garansi.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : CustomButton(
                      backgroundColor: ColorTheme.neonYellow,
                      icon: Icons.send,
                      foregroundColor: Colors.black,
                      text: 'Ajukan Klaim Garansi',
                      onPressed: controller.submitWarrantyClaim,
                      width: double.infinity,
                    );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
