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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Riwayat Booking',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: ColorTheme.primary,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: ColorTheme.primary,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
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
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildTabContent(
                    'Terverifikasi',
                    Icons.verified,
                    Colors.orange,
                  ),
                  _buildTabContent(
                    'Sedang Dikerjakan',
                    Icons.build,
                    Colors.blue,
                  ),
                  _buildTabContent('Selesai', Icons.check_circle, Colors.green),
                  _buildTabContent('Dibatalkan', Icons.cancel, Colors.red),
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
        return const Center(child: CircularProgressIndicator());
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
              Icon(icon, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Belum ada booking dengan status $status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchBookings(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: ColorTheme.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking ${controller.formatBookingId(booking.id)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    // const SizedBox(width: 4),
                    // Text(
                    //   status,
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 6,
                    //     fontWeight: FontWeight.w500,
                    //     color: color,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Motor info
          if (motorcycleInfo.isNotEmpty)
            _buildInfoRow(Icons.motorcycle, motorcycleInfo),
          if (motorcycleInfo.isNotEmpty) const SizedBox(height: 8),

          // Service info
          if (servicesInfo.isNotEmpty) _buildInfoRow(Icons.build, servicesInfo),
          if (servicesInfo.isNotEmpty) const SizedBox(height: 8),

          // Date info
          if (dateTimeInfo.isNotEmpty)
            _buildInfoRow(Icons.calendar_today, dateTimeInfo),
          if (dateTimeInfo.isNotEmpty) const SizedBox(height: 8),

          // Complaint
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            _buildInfoRow(
              Icons.comment,
              booking.complaint!,
              isExpandable: true,
            ),
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            const SizedBox(height: 8),

          // Total Price
          if (booking.totalPrice != null)
            Row(
              children: [
                Icon(Icons.payment, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total: ${controller.formatPrice(booking.totalPrice)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.primary,
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
                    side: BorderSide(color: ColorTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      color: ColorTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showActionModal(status, booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Aksi',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  void _showBookingDetailModal(BookingsModel booking) {
    CustomModal.showBottomSheet(
      title: 'Detail Booking',
      height: Get.height * 0.7,
      content: Column(
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

          // _buildDetailRow(
          //   'Diverifikasi Oleh',
          //   booking.verifiedBy != null ? booking.verifiedBy!.join(', ') : '-',
          // ),
          if (booking.complaint != null && booking.complaint!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Keluhan:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                booking.complaint!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'Catatan Teknisi / Admin:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.notes ?? 'Belum ada catatan',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
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
            icon: Icons.cancel,
            isDestructive: true,
            onPressed: () => controller.cancelBooking(booking),
          ),
        ];
        break;
      case 'Dalam Pengerjaan':
        actions = [
          ActionSheetItem(
            title: 'Hubungi Teknisi',
            icon: Icons.phone,
            onPressed: () => controller.contactTechnician(booking),
          ),
          ActionSheetItem(
            title: 'Lihat Progress',
            icon: Icons.timeline,
            onPressed: () => controller.viewProgress(booking),
          ),
        ];
        break;
      case 'Selesai':
        actions = [
          ActionSheetItem(
            title: 'Konfirmasi Pengambilan',
            icon: Icons.check_circle,
            onPressed: () => controller.confirmPickup(booking),
          ),
        ];
        break;
      case 'Diambil':
        actions = [
          ActionSheetItem(
            title: 'Beri Rating',
            icon: Icons.star,
            onPressed: () => controller.rateService(booking),
          ),
          ActionSheetItem(
            title: 'Download Invoice',
            icon: Icons.download,
            onPressed: () => controller.downloadInvoice(booking),
          ),
        ];
        break;
    }

    CustomModal.showActionSheet(title: 'Pilih Aksi', actions: actions);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
