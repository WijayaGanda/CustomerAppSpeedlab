import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/info_card.dart';
import '../controllers/riwayat_servis_controller.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';

class RiwayatServisView extends GetView<RiwayatServisController> {
  const RiwayatServisView({super.key});

  String _formatCurrency(int? amount) {
    if (amount == null) return 'Rp 0';
    final intPrice = amount.toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final formatted = intPrice.replaceAllMapped(regex, (match) => '${match[1]}.');
    return 'Rp $formatted';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Koridor light background
      appBar: AppBar(
        title: Text(
          'Detail Riwayat Servis',
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
      body: Obx(() {
        
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: ColorTheme.neonYellow),
          );
        }

        if (controller.serviceHistory.isEmpty) {
          return _buildEmptyState();
        }

        final history = controller.serviceHistory.first;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              _buildMainInfoCard(history),
              const SizedBox(height: 20),
              if (history.spareParts != null && history.spareParts!.isNotEmpty)
                _buildSparePartsCard(history.spareParts!),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 56,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Riwayat',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teknisi belum menambahkan catatan\npekerjaan untuk servis ini.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(ServiceHistoryModel history) {
    return Container(
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
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detail Pekerjaan",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    history.status ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFF4F6F9), thickness: 1.5),
            ),
            InfoRow(
              icon: Icons.person_rounded,
              label: "Mekanik Utama",
              value: history.mechanicName ?? "Belum ditentukan",
              iconColor: Colors.black87,
            ),
            InfoRow(
              icon: Icons.build_circle_rounded,
              label: "Diagnosa",
              value: history.diagnosis ?? "-",
              iconColor: Colors.black87,
            ),
            InfoRow(
              icon: Icons.check_circle_rounded,
              label: "Pekerjaan Selesai",
              value: history.workDone ?? "-",
              iconColor: Colors.black87,
            ),
            InfoRow(
              icon: Icons.calendar_month_rounded,
              label: "Waktu Selesai",
              value: _formatDate(history.endDate),
              iconColor: Colors.black87,
            ),
            InfoRow(
              icon: Icons.security_rounded,
              label: "Batas Garansi",
              value: _formatDate(history.warrantyExpiry),
              iconColor: Colors.black87,
            ),
            
            if (history.notes != null && history.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Catatan Tambahan:",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTheme.neonYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorTheme.neonYellow.withOpacity(0.5)),
                ),
                child: Text(
                  history.notes!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFF4F6F9), thickness: 1.5),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.payments_rounded, color: Colors.black87, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Biaya Servis",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatCurrency(history.totalPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparePartsCard(List<ServiceHistorySparePart> spareparts) {
    return Container(
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
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings_suggest_rounded, color: Colors.black87, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  "Suku Cadang",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spareparts.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF4F6F9), thickness: 1.5),
              itemBuilder: (context, index) {
                final part = spareparts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${part.quantity}x",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.name ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "@ ${_formatCurrency(part.price)}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatCurrency((part.price ?? 0) * (part.quantity ?? 0)),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
