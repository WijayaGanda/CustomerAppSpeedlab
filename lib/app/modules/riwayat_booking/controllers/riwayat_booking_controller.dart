import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/payments_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/utils/helper/pdf_helper.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
// import 'package:speedlab_pelanggan/app/modules/payment_webview/views/payment_webview_view.dart';

class RiwayatBookingController extends GetxController {
  final BookingsProvider provider;
  final PaymentProvider paymentProvider;
  final ServiceHistoryProvider serviceHistoryProvider;
  final authService = Get.find<AuthService>();

  RiwayatBookingController({
    required this.provider,
    required this.paymentProvider,
    required this.serviceHistoryProvider,
  });

  var bookings = <BookingsModel>[].obs;
  var paymentsResponse = <PaymentResponse>[].obs;
  var paymentsStatus =
      <String, PaymentStatusResponse>{}.obs; // Map per booking ID
  var isLoading = false.obs;
  var isProcessingPayment = false.obs;
  var serviceHistory = <ServiceHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> paymentStatusCheck(String bookingId) async {
    try {
      final response = await paymentProvider.getPaymentStatus(bookingId);
      if (response.isOk && response.body['success'] == true) {
        final statusResponse = PaymentStatusResponse.fromJson(
          response.body['data'],
        );
        paymentsStatus[bookingId] = statusResponse; // Store by booking ID
      }
    } catch (e) {
      print('Error checking payment status for booking $bookingId: $e');
    }
  }

  Future<void> fetchAllPaymentStatus() async {
    try {
      // Fetch payment status untuk semua booking
      for (var booking in bookings) {
        if (booking.id != null) {
          await paymentStatusCheck(booking.id!);
        }
      }
    } catch (e) {
      print('Error fetching all payment status: $e');
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchMyBookings();
      if (response.isOk) {
        final bookingsResponse = BookingsResponse.fromJson(response.body);
        bookings.value = bookingsResponse.data ?? [];

        // Fetch payment status untuk semua booking setelah data bookings berhasil diambil
        if (bookings.isNotEmpty) {
          await fetchAllPaymentStatus();
        }
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

  Future<void> makeDownPaymentAPI(String? id) async {
    debugPrint("=== ID BOOKING YANG MAU DIBAYAR: $id ===");

    if (id == null || id.isEmpty) {
      Get.snackbar("Error", "ID Booking tidak ditemukan!");
      return; // Hentikan fungsi jika ID kosong
    }
    isProcessingPayment.value = true;
    try {
      // 1. Minta Token dan URL ke Express.js
      final response = await paymentProvider.createPayment(id);

      if (response.statusCode == 200 && response.body['success'] == true) {
        String redirectUrl = response.body['redirect_url'];

        // 2. Buka WebView Midtrans
        final result = await Get.toNamed(
          '/payment-webview',
          arguments: redirectUrl,
        );

        // 3. Setelah WebView ditutup (user selesai di Midtrans)
        if (result == true) {
          Get.snackbar("Info", "Memeriksa status pembayaran...");
          fetchBookings(); // Refresh data setelah pembayaran
        }
      } else {
        Get.snackbar("Gagal", response.body['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung ke server pembayaran");
      print(e);
    } finally {
      isProcessingPayment.value = false;
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

  // ========== PAYMENT STATUS METHODS ==========
  String getPaymentStatus(String? bookingId) {
    if (bookingId == null) return '-';
    final paymentStatus = paymentsStatus[bookingId];
    if (paymentStatus == null) return '-';
    return formatPaymentStatus(paymentStatus.transactionStatus);
  }

  PaymentStatusResponse? getPaymentStatusObject(String? bookingId) {
    if (bookingId == null) return null;
    return paymentsStatus[bookingId];
  }

  String formatPaymentStatus(String? status) {
    if (status == null || status.isEmpty) return '-';

    switch (status.toLowerCase()) {
      case 'settlement':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'expire':
        return 'Pembayaran Kadaluarsa';
      case 'cancel':
        return 'Pembayaran Dibatalkan';
      case 'deny':
        return 'Pembayaran Ditolak';
      case 'failure':
        return 'Pembayaran Gagal';
      default:
        return status;
    }
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

  void makeDownPayment(BookingsModel booking) {
    Get.dialog(
      AlertDialog(
        title: Text('Bayar DP', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text(
          'Anda akan diarahkan ke halaman pembayaran untuk booking ${formatBookingId(booking.id)}. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              makeDownPaymentAPI(booking.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Ya, Bayar', style: TextStyle(color: Colors.white)),
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
    Get.toNamed('/riwayat-servis', arguments: booking);
  }

  void rateService(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Fitur rating akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void fetchServiceHistory(String bookingId) async {
    isLoading.value = true;
    try {
      final response = await serviceHistoryProvider.getServiceHistory(
        bookingId,
      );
      if (response.isOk) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        if (serviceHistoryResponse.data != null) {
          serviceHistory.value = [serviceHistoryResponse.data!];
          debugPrint("berhasil fetch service history");

          if (serviceHistory.isNotEmpty &&
              serviceHistory.first.status?.toLowerCase() == 'selesai') {
            debugPrint("Service history selesai");
            // disableForm();
          }
        } else {
          serviceHistory.value = [];
          debugPrint("Service history data kosong");
        }
      } else {
        debugPrint("Gagal fetch service history: ${response.statusCode}");
        CustomSnackbar.error("Error", "Gagal memuat riwayat servis");
      }
    } catch (e) {
      debugPrint('Error fetching service history: $e');
      CustomSnackbar.error("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadInvoice(BookingsModel booking) async {
    try {
      isLoading.value = true;

      // Fetch service history terlebih dahulu
      if (booking.id != null) {
        fetchServiceHistory(booking.id!);
      }

      // Generate invoice dengan data dari booking
      List<Map<String, dynamic>> sparePartsList = [];
      if (serviceHistory.isNotEmpty &&
          serviceHistory.first.spareParts != null &&
          serviceHistory.first.spareParts!.isNotEmpty) {
        sparePartsList =
            serviceHistory.first.spareParts!
                .map(
                  (part) => {
                    'name': part.name ?? 'Spare Part',
                    'price': part.price ?? 0,
                    'quantity': part.quantity ?? 1,
                  },
                )
                .toList();
      }

      PdfHelper.generateAndDownloadInvoice(
        bookingId: booking.id ?? '-',
        customerName: authService.user.value?.name ?? 'Pelanggan Speedlab',
        status: booking.status ?? '-',
        totalAmount: booking.totalPrice ?? 0,
        date: booking.bookingDate?.toLocal().toString().split(' ')[0] ?? '-',
        servicesName:
            booking.serviceIds != null
                ? booking.serviceIds!
                    .map(
                      (s) =>
                          s is Map && s['name'] != null ? s['name'] : 'Layanan',
                    )
                    .toList()
                : ['Layanan'],
        servicesPrice:
            booking.serviceIds != null
                ? booking.serviceIds!
                    .map((s) => s is Map && s['price'] != null ? s['price'] : 0)
                    .toList()
                : [0],
        spareParts: sparePartsList.isNotEmpty ? sparePartsList : null,
        serviceHistoryTotalPrice:
            serviceHistory.isNotEmpty && serviceHistory.first.totalPrice != null
                ? serviceHistory.first.totalPrice!
                : null,
      );

      Get.back();
      CustomSnackbar.success("Sukses", "Invoice berhasil diunduh");
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal mengunduh invoice: $e");
      debugPrint('Error download invoice: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
