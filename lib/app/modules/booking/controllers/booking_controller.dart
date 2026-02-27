import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class BookingController extends GetxController {
  final BookingsProvider provider;
  final ServiceProvider serviceProvider;
  final AuthService authService;
  BookingController({
    required this.provider,
    required this.serviceProvider,
    required this.authService,
  });

  final complaintCtrl = TextEditingController();
  var selectedMotor = Rxn<MotorModel>();
  var availableServices = <ServiceModel>[].obs;
  var selectedService = <ServiceModel>[].obs;
  var isLoading = false.obs;

  // Tanggal dan waktu booking
  var selectedDateTime = Rxn<DateTime>();

  // Getter untuk tampilan
  String get bookingDate =>
      selectedDateTime.value != null
          ? DateFormat('dd/MM/yyyy').format(selectedDateTime.value!)
          : '';

  String get bookingTime =>
      selectedDateTime.value != null
          ? DateFormat('HH:mm').format(selectedDateTime.value!)
          : '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedMotor.value = Get.arguments as MotorModel;
      debugPrint("📢 Received motor argument: ${selectedMotor.value?.id}");
    }

    // Set tanggal dan waktu saat ini
    selectedDateTime.value = DateTime.now();

    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final response = await serviceProvider.fetchServices();
      if (response.isOk && response.body != null) {
        availableServices.value = List<ServiceModel>.from(
          response.body['data'].map((x) => ServiceModel.fromJson(x)),
        );
      } else {
        CustomSnackbar.error(
          "Error",
          response.body?['message'] ?? 'Gagal mengambil data layanan',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(ServiceModel service, bool isChecked) {
    if (isChecked) {
      selectedService.add(service);
    } else {
      selectedService.removeWhere((s) => s.id == service.id);
    }
  }

  Future<void> submitBooking() async {
    debugPrint("🚀 Submit booking called");
    debugPrint("Selected services: ${selectedService.length}");
    debugPrint("Selected motor: ${selectedMotor.value?.id}");

    if (selectedService.isEmpty) {
      CustomSnackbar.error("Error", "Pilih minimal satu layanan");
      return;
    }

    try {
      isLoading.value = true;
      debugPrint("📤 Sending booking request...");

      // Format DateTime ke ISO 8601 untuk server
      final bookingDateTime = selectedDateTime.value ?? DateTime.now();
      final isoDateTime = bookingDateTime.toIso8601String();

      debugPrint("📅 Booking DateTime: $isoDateTime");

      final response = await provider.addBooking({
        'motorcycleId': selectedMotor.value?.id,
        'serviceIds': selectedService.map((s) => s.id).toList(),
        'bookingDate': isoDateTime,
        'bookingTime': isoDateTime,
        'complaint': complaintCtrl.text,
      });

      debugPrint("📥 Response received: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.isOk && response.body != null) {
        CustomSnackbar.success("Sukses", "Booking berhasil dibuat");
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error(
          "Error",
          response.body?['message'] ?? 'Gagal membuat booking',
        );
      }
    } catch (e) {
      debugPrint("❌ Error during booking: $e");
      CustomSnackbar.error("Error", "Terjadi kesalahan: $e");
    } finally {
      debugPrint("✅ Setting isLoading to false");
      isLoading.value = false;
    }
  }

  // Method untuk memilih tanggal
  Future<void> pickDate(BuildContext context) async {
    final currentDateTime = selectedDateTime.value ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      // Gabungkan tanggal baru dengan waktu yang sudah ada
      selectedDateTime.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDateTime.hour,
        currentDateTime.minute,
      );
    }
  }

  // Method untuk memilih waktu
  Future<void> pickTime(BuildContext context) async {
    final currentDateTime = selectedDateTime.value ?? DateTime.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
    );

    if (picked != null) {
      // Gabungkan waktu baru dengan tanggal yang sudah ada
      selectedDateTime.value = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        picked.hour,
        picked.minute,
      );
    }
  }
}
