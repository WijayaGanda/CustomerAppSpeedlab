import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/payments_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/utils/helper/pdf_helper.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:speedlab_pelanggan/app/modules/payment_webview/views/payment_webview_view.dart';

class RiwayatBookingController extends GetxController {
  final BookingsProvider provider;
  final PaymentProvider paymentProvider;
  final ServiceHistoryProvider serviceHistoryProvider;
  final AuthService authService;
  RiwayatBookingController({
    required this.provider,
    required this.paymentProvider,
    required this.serviceHistoryProvider,
    required this.authService,
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

  void openModalFromNotification(String bookingId) async {
    debugPrint("Mencari data untuk booking ID: $bookingId");
    await fetchBookings();

    // fetchServiceHistory(bookingId);

    if (bookings.isEmpty) {
      once(bookings, (_) {
        _findAndShowModal(bookingId);
      });
    } else {
      _findAndShowModal(bookingId);
    }
  }

  void _findAndShowModal(String bookingId) {
    var targetBooking = bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => BookingsModel(),
    );
    if (targetBooking.id != null) {
      // Delay sedikit (300ms) agar modal muncul dengan mulus tanpa patah-patah
      Future.delayed(const Duration(milliseconds: 300), () {
        showBookingDetailModal(targetBooking);
      });
    } else {
      debugPrint("Booking dengan ID $bookingId tidak ditemukan di daftar.");
    }
  }

  void showBookingDetailModal(BookingsModel booking) {
    CustomModal.showBottomSheet(
      title: 'Detail Booking',
      height: Get.height * 0.75,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('No. Booking', formatBookingId(booking.id)),
              _buildDetailRow('Motor', getMotorcycleInfo(booking)),
              _buildDetailRow('Layanan', getServicesInfo(booking)),
              _buildDetailRow('Tanggal', formatDate(booking.bookingDate)),
              _buildDetailRow(
                'Waktu',
                '${formatTime(booking.bookingTime)} WIB',
              ),
              _buildDetailRow(
                'Estimasi Selesai',
                '${formatEstimatedTime(booking)} WIB',
              ),
              _buildDetailRow(
                'Total Biaya',
                formatPrice(booking.totalPrice?.toInt()),
              ),
              _buildDetailRow('Status', booking.status ?? '-'),
              _buildDetailRow('DP Pembayaran', getPaymentStatus(booking.id)),

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
      CustomSnackbar.error('Error', 'Gagal memeriksa status pembayaran');
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
      CustomSnackbar.error('Error', 'Gagal mengambil status pembayaran');
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
        if (serviceHistory.isNotEmpty && serviceHistory.first.id != null) {
          fetchServiceHistory(bookings.first.id!);
        }
      } else {
        CustomSnackbar.error("Error", 'Gagal memuat riwayat booking');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal memuat riwayat booking');
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
        fetchBookings();
      } else {
        String errorMsg =
            response.body?['message'] ?? "Gagal membatalkan booking";
        CustomSnackbar.error("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal membatalkan booking');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makeDownPaymentAPI(String? id) async {
    debugPrint("=== ID BOOKING YANG MAU DIBAYAR: $id ===");

    if (id == null || id.isEmpty) {
      CustomSnackbar.error("Error", "ID Booking tidak ditemukan!");
      return;
    }

    isProcessingPayment.value = true;

    try {
      // 1. Minta Token dan URL ke Express.js
      final response = await paymentProvider.createPayment(id);

      if (response.statusCode == 200 && response.body['success'] == true) {
        String redirectUrl = response.body['redirect_url'];

        //  CEK PLATFORM: WEB ATAU MOBILE?
        if (kIsWeb) {
          // --- 🌐 LOGIKA KHUSUS WEB ---
          final Uri url = Uri.parse(redirectUrl);
          if (await canLaunchUrl(url)) {
            // Buka Midtrans di tab browser baru
            await launchUrl(url, mode: LaunchMode.platformDefault);

            // Karena di web kita tidak bisa mendeteksi kapan tab Midtrans ditutup,
            // kita berikan dialog popup agar user bisa memicu refresh data secara manual.
            Get.defaultDialog(
              title: "Lanjut ke Pembayaran",
              content: Column(
                children: [
                  Text(
                    "Klik link di bawah ini untuk membuka halaman pembayaran:",
                  ),
                  SizedBox(height: 10),
                  SelectableText(
                    redirectUrl,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              textConfirm: "Sudah Bayar",
              onConfirm: () => fetchBookings(),
            );
          } else {
            CustomSnackbar.error(
              "Error",
              "Gagal membuka tautan pembayaran di Web.",
            );
          }
        } else {
          // --- LOGIKA KHUSUS MOBILE (ANDROID/IOS) ---
          // 2. Buka WebView Midtrans (Tetap gunakan kode asli Anda)
          final result = await Get.toNamed(
            '/payment-webview',
            arguments: redirectUrl,
          );

          // 3. Setelah WebView ditutup (user selesai di Midtrans)
          if (result == true) {
            CustomSnackbar.error("Info", "Memeriksa status pembayaran...");
            fetchBookings(); // Refresh data setelah pembayaran
          }
        }
      } else {
        CustomSnackbar.error(
          "Gagal",
          response.body['message'] ?? "Terjadi kesalahan",
        );
      }
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal terhubung ke server pembayaran");
      debugPrint(e.toString());
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
    if (booking.bookingDetails == null || booking.bookingDetails!.isEmpty) {
      return '';
    }

    List<String> serviceDetails = [];
    for (var detail in booking.bookingDetails!) {
      String serviceName = detail.serviceName ?? '';

      // 1. Ambil Variant
      String variant = detail.selectedVariant ?? '';
      String variantStr = variant.isNotEmpty ? ' ($variant)' : '';

      // 2. Ambil Addons (Trik Baru!)
      String addonsStr = '';
      if (detail.selectedAddons != null && detail.selectedAddons!.isNotEmpty) {
        // Ambil semua nama addon, gabungkan dengan koma
        List<String> addonNames =
            detail.selectedAddons!
                .map((addon) => addon.name ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

        if (addonNames.isNotEmpty) {
          // Format tampilannya, misal: " [+ Dyno Rental, Cuci Motor]"
          addonsStr = ' [+ ${addonNames.join(', ')}]';
        }
      }

      // 3. Gabungkan Semuanya: Nama Service + Variant + Addons
      serviceDetails.add('$serviceName$variantStr$addonsStr');
    }

    // Kembalikan hasilnya. (Pakai '\n' agar kalau layanannya banyak, dia turun ke baris baru biar rapi)
    return serviceDetails.join('\n');
  }

  // ========== FORMATTING METHODS ==========
  String formatDateTime(BookingsModel booking) {
    if (booking.bookingDate == null || booking.bookingTime == null) return '';

    final dateFormat = DateFormat('dd MMM yyyy');
    return '${dateFormat.format(booking.bookingDate!)}, ${booking.bookingTime!} WIB';
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
    if (booking.bookingTime == null || booking.bookingDate == null) return '-';

    try {
      final timeParts = booking.bookingTime!.split(':');
      if (timeParts.length != 2) return '-';

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      DateTime bookingDateTime = DateTime(
        booking.bookingDate!.year,
        booking.bookingDate!.month,
        booking.bookingDate!.day,
        hour,
        minute,
      );

      final estimated = bookingDateTime.add(const Duration(hours: 2));
      return DateFormat('HH:mm').format(estimated);
    } catch (e) {
      return '-';
    }
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

  String formatTime(dynamic time) {
    if (time == null) return '-';
    if (time is DateTime) return DateFormat('HH:mm').format(time);
    if (time is String) return time;
    return '-';
  }

  // ========== WARRANTY METHODS ==========
  Future<DateTime?> getWarrantyExpiryForBooking(String bookingId) async {
    try {
      final response = await serviceHistoryProvider.getServiceHistory(
        bookingId,
      );
      if (response.isOk) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        return serviceHistoryResponse.data?.warrantyExpiry;
      }
    } catch (e) {
      debugPrint('Error fetching warranty expiry: $e');
    }
    return null;
  }

  bool isWarrantyExpired(DateTime? warrantyExpiry) {
    if (warrantyExpiry == null) return false;
    return DateTime.now().isAfter(warrantyExpiry);
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

  void claimGaransi(BookingsModel booking) {
    Get.toNamed('/klaim-garansi', arguments: booking);
  }

  void fetchWarrantyClaims(BookingsModel booking) {
    Get.toNamed('/status-klaim-garansi', arguments: booking);
  }

  void rateService(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Fitur rating akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> fetchServiceHistory(String bookingId) async {
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

      if (booking.id != null) {
        await fetchServiceHistory(booking.id!);
      }

      // 1. Ambil data Spareparts
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

      /// 2. EXTRACT LAYANAN DARI bookingDetails (Bukan serviceIds lagi)
      List<String> finalServiceNames = [];
      List<int> finalServicePrices = [];

      if (booking.bookingDetails != null &&
          booking.bookingDetails!.isNotEmpty) {
        for (var detail in booking.bookingDetails!) {
          // Baris 1: Nama Layanan (Pakai bullet point)
          String sName = "- ${detail.serviceName ?? 'Layanan'}";
          // Baris 2: Varian (Turun ke bawah agak menjorok)
          if (detail.selectedVariant != null &&
              detail.selectedVariant!.isNotEmpty) {
            sName += '\n    Varian: ${detail.selectedVariant}';
          }

          // Baris 3: Addons (Turun ke bawah agak menjorok)
          if (detail.selectedAddons != null &&
              detail.selectedAddons!.isNotEmpty) {
            List<String> addonNames =
                detail.selectedAddons!
                    .map((a) => a.name ?? '')
                    .where((n) => n.isNotEmpty)
                    .toList();
            if (addonNames.isNotEmpty) {
              sName += '\n    Addons: ${addonNames.join(', ')}';
            }
          }

          finalServiceNames.add(sName);
          finalServicePrices.add(detail.subtotal?.toInt() ?? 0);
        }
      } else {
        // Fallback jika kosong
        finalServiceNames.add('- Layanan Servis Umum');
        finalServicePrices.add(booking.servicePrice?.toInt() ?? 0);
      }

      // 3. Generate PDF
      await PdfHelper.generateAndDownloadInvoice(
        bookingId: booking.id ?? '-',
        customerName: authService.user.value?.name ?? 'Pelanggan Speedlab',
        status: booking.status ?? '-',
        totalAmount: booking.totalPrice?.toInt() ?? 0,
        date: booking.bookingDate?.toLocal().toString().split(' ')[0] ?? '-',
        servicesName: finalServiceNames, // ✅ Pakai data yang baru diekstrak
        servicesPrice: finalServicePrices, // ✅ Pakai data yang baru diekstrak
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
