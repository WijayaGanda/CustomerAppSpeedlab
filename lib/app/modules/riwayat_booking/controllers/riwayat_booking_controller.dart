import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class RiwayatBookingController extends GetxController {
  final BookingsProvider provider;

  RiwayatBookingController({required this.provider});

  var bookings = <BookingsModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchMyBookings();
      if (response.isOk) {
        final bookingsResponse = BookingsResponse.fromJson(response.body);
        bookings.value = bookingsResponse.data ?? [];
      } else {
        CustomSnackbar.error("Error", 'Gagal memuat riwayat booking');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat booking');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBookingAPI(String id) async {
    try {
      isLoading.value = true;
      final response = await provider.cancelBooking(id);
      if (response.isOk) {
        CustomSnackbar.success("Berhasil", "Booking berhasil dibatalkan");
        fetchBookings(); // Refresh data setelah pembatalan
      } else {
        String errorMsg =
            response.body?['message'] ?? "Gagal membatalkan booking";
        Get.snackbar("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan booking');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== FILTERING METHODS ==========
  List<BookingsModel> getBookingsByStatus(String status) {
    return bookings.where((booking) {
      String apiStatus = booking.status ?? '';
      switch (status) {
        case 'Menunggu Verifikasi':
          return apiStatus.toLowerCase() == 'menunggu verifikasi';
        case 'Terverifikasi':
          return apiStatus.toLowerCase() == 'terverifikasi';
        case 'Sedang Dikerjakan':
          return apiStatus.toLowerCase() == 'sedang dikerjakan';
        case 'Selesai':
          return apiStatus.toLowerCase() == 'selesai';
        case 'Dibatalkan':
          return apiStatus.toLowerCase() == 'dibatalkan';
        default:
          return false;
      }
    }).toList();
  }

  // ========== DATA PARSING METHODS ==========
  String getMotorcycleInfo(BookingsModel booking) {
    if (booking.motorcycleId == null) return '';

    final motorcycle = booking.motorcycleId!;
    String brand = motorcycle['brand'] ?? '';
    String model = motorcycle['model'] ?? '';
    String year = motorcycle['year']?.toString() ?? '';
    String licensePlate = motorcycle['licensePlate'] ?? '';

    return '$brand $model $year - $licensePlate';
  }

  String getServicesInfo(BookingsModel booking) {
    if (booking.serviceIds == null || booking.serviceIds!.isEmpty) return '';

    List<String> serviceNames = [];
    for (var service in booking.serviceIds!) {
      if (service is Map && service['name'] != null) {
        serviceNames.add(service['name']);
      }
    }
    return serviceNames.join(', ');
  }

  // ========== FORMATTING METHODS ==========
  String formatDateTime(BookingsModel booking) {
    if (booking.bookingDate == null || booking.bookingTime == null) return '';

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(booking.bookingDate!)}, ${timeFormat.format(booking.bookingTime!)} WIB';
  }

  String formatPrice(int? price) {
    if (price == null) return 'Belum ditentukan';
    return 'Rp ${NumberFormat('#,###').format(price)}';
  }

  String formatBookingId(String? id) {
    if (id == null) return 'Unknown';
    return '#${id.substring(0, 8)}';
  }

  String formatEstimatedTime(BookingsModel booking) {
    if (booking.bookingTime == null) return '-';
    final estimated = booking.bookingTime!.add(const Duration(hours: 2));
    return DateFormat('HH:mm').format(estimated);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('HH:mm').format(time);
  }

  // ========== ACTION METHODS ==========
  void cancelBooking(BookingsModel booking) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Batalkan Booking',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan booking ${formatBookingId(booking.id)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelBookingAPI(booking.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void confirmPickup(BookingsModel booking) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Konfirmasi Pengambilan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Konfirmasi bahwa Anda sudah mengambil motor untuk booking ${formatBookingId(booking.id)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Belum', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement pickup confirmation API call
              Get.snackbar(
                'Berhasil',
                'Pengambilan motor telah dikonfirmasi',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[100],
                colorText: Colors.green[800],
              );
            },
            child: Text(
              'Ya, Sudah Diambil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void contactTechnician(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Menghubungi teknisi untuk booking ${formatBookingId(booking.id)}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewProgress(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Progress booking dapat dilihat di detail',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void rateService(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Fitur rating akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void downloadInvoice(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Mengunduh invoice untuk booking ${formatBookingId(booking.id)}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }
}
