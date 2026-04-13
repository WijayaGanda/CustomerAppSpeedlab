import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import '../controllers/riwayat_booking_controller.dart';

class RiwayatBookingView extends GetView<RiwayatBookingController> {
  const RiwayatBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF4F6F9,
        ), // Koridor putih/abu-abu bersih
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black, // Koridor identitas hitam
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Riwayat Booking',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                controller.fetchBookings();
              },
              icon: Icon(Icons.refresh_rounded),
              color: Colors.white,
            ),
          ],
          // centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.black, // Tab panel konsisten hitam
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: ColorTheme.neonYellow, // Identitas Neon Yellow
                indicatorWeight: 4,
                labelColor: ColorTheme.neonYellow,
                unselectedLabelColor: Colors.grey[400],
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Menunggu Verifikasi'),
                  Tab(text: 'Terverifikasi'),
                  Tab(text: 'Sedang Dikerjakan'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Dibatalkan'),
                ],
              ),
            ),
            // Add refresh button
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(
                    'Menunggu Verifikasi',
                    Icons.hourglass_empty_rounded,
                    Colors.orange,
                  ),
                  _buildTabContent(
                    'Terverifikasi',
                    Icons.verified_rounded,
                    Colors.blue,
                  ),
                  _buildTabContent(
                    'Sedang Dikerjakan',
                    Icons.build_circle_rounded,
                    Colors.teal,
                  ),
                  _buildTabContent(
                    'Selesai',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                  _buildTabContent(
                    'Dibatalkan',
                    Icons.cancel_rounded,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String status, IconData icon, Color color) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: ColorTheme.neonYellow),
        );
      }

      // Use controller method for filtering
      List<BookingsModel> filteredBookings = controller.getBookingsByStatus(
        status,
      );

      if (filteredBookings.isEmpty) {
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
                child: Icon(icon, size: 56, color: Colors.black38),
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
                'Tidak ada booking dengan status\n"$status"',
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

      return RefreshIndicator(
        onRefresh: () => controller.fetchBookings(),
        color: Colors.black,
        backgroundColor: ColorTheme.neonYellow,
        child: ListView.separated(
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 40,
          ),
          itemCount: filteredBookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return _buildBookingCard(booking, status, icon, color);
          },
        ),
      );
    });
  }

  Widget _buildBookingCard(
    BookingsModel booking,
    String status,
    IconData icon,
    Color color,
  ) {
    // Use controller methods for data parsing
    final motorcycleInfo = controller.getMotorcycleInfo(booking);
    final servicesInfo = controller.getServicesInfo(booking);
    final dateTimeInfo = controller.formatDateTime(booking);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ID: ${controller.formatBookingId(booking.id)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF4F6F9), thickness: 1.5),
          ),

          // Motor info
          if (motorcycleInfo.isNotEmpty)
            _buildInfoRow(Icons.two_wheeler_rounded, motorcycleInfo),
          if (motorcycleInfo.isNotEmpty) const SizedBox(height: 10),

          // Service info
          if (servicesInfo.isNotEmpty)
            _buildInfoRow(Icons.miscellaneous_services_rounded, servicesInfo),
          if (servicesInfo.isNotEmpty) const SizedBox(height: 10),

          // Date info
          if (dateTimeInfo.isNotEmpty)
            _buildInfoRow(Icons.calendar_month_rounded, dateTimeInfo),
          if (dateTimeInfo.isNotEmpty) const SizedBox(height: 10),

          // Complaint
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            _buildInfoRow(
              Icons.format_quote_rounded,
              booking.complaint!,
              isExpandable: true,
            ),
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            const SizedBox(height: 10),

          // Total Price
          if (booking.totalPrice != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.payments_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Total: ${controller.formatPrice(booking.totalPrice)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

          if (booking.totalPrice != null) const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showBookingDetailModal(booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              // Show action button only if status is not "Dibatalkan"
              if (status != 'Dibatalkan' && status != 'Terverifikasi') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showActionModal(status, booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.neonYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Aksi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    bool isExpandable = false,
  }) {
    return Row(
      crossAxisAlignment:
          isExpandable ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.black87, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding:
                isExpandable
                    ? const EdgeInsets.only(top: 4.0)
                    : EdgeInsets.zero,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetailModal(BookingsModel booking) {
    CustomModal.showBottomSheet(
      title: 'Detail Booking',
      height: Get.height * 0.75,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'No. Booking',
                controller.formatBookingId(booking.id),
              ),
              _buildDetailRow('Motor', controller.getMotorcycleInfo(booking)),
              _buildDetailRow('Layanan', controller.getServicesInfo(booking)),
              _buildDetailRow(
                'Tanggal',
                controller.formatDate(booking.bookingDate),
              ),
              _buildDetailRow(
                'Waktu',
                '${controller.formatTime(booking.bookingTime)} WIB',
              ),
              _buildDetailRow(
                'Estimasi Selesai',
                '${controller.formatEstimatedTime(booking)} WIB',
              ),
              _buildDetailRow(
                'Total Biaya',
                controller.formatPrice(booking.totalPrice),
              ),
              _buildDetailRow('Status', booking.status ?? '-'),
              _buildDetailRow(
                'DP Pembayaran',
                controller.getPaymentStatus(booking.id),
              ),

              if (booking.complaint != null &&
                  booking.complaint!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Keluhan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.complaint!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Tutup",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionModal(String status, BookingsModel booking) {
    List<ActionSheetItem> actions = [];

    switch (status) {
      case 'Menunggu Verifikasi':
        actions = [
          ActionSheetItem(
            title: 'Batalkan Booking',
            icon: Icons.cancel_rounded,
            isDestructive: true,
            onPressed: () => controller.cancelBooking(booking),
          ),
          ActionSheetItem(
            title: 'Bayar DP',
            icon: Icons.monetization_on_rounded,
            isDestructive: false,
            onPressed: () => controller.makeDownPayment(booking),
          ),
        ];
        break;
      case 'Sedang Dikerjakan':
        actions = [
          ActionSheetItem(
            title: 'Hubungi Teknisi',
            icon: Icons.phone_rounded,
            onPressed: () => controller.contactTechnician(booking),
          ),
          ActionSheetItem(
            title: 'Lihat Progress',
            icon: Icons.timeline_rounded,
            onPressed: () => controller.viewProgress(booking),
          ),
        ];
        break;
      case 'Selesai':
        actions = [
          ActionSheetItem(
            title: 'Konfirmasi Pengambilan',
            icon: Icons.check_circle_rounded,
            onPressed: () => controller.confirmPickup(booking),
          ),
          ActionSheetItem(
            title: 'Download Invoice',
            icon: Icons.download_rounded,
            onPressed: () => controller.downloadInvoice(booking),
          ),
          ActionSheetItem(
            title: 'Lihat Riwayat Servis',
            icon: Icons.timeline_rounded,
            onPressed: () => controller.viewProgress(booking),
          ),
        ];
        break;
      case 'Diambil':
        actions = [
          ActionSheetItem(
            title: 'Beri Rating',
            icon: Icons.star_rounded,
            onPressed: () => controller.rateService(booking),
          ),
        ];
        break;
    }

    CustomModal.showActionSheet(title: 'Pilih Aksi', actions: actions);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
