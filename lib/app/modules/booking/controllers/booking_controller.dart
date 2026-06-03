import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
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
  var selectedVariants = <String, Variant?>{}.obs;
  var selectedAddons = <String, List<Addon>>{}.obs;
  var isLoading = false.obs;

  // Tanggal dan waktu booking
  var selectedDateTime = Rxn<DateTime>();
  var isTimeSelected = false.obs; // Track apakah waktu sudah dipilih

  // Track booked time slots untuk tanggal yang dipilih
  var bookedTimes = <DateTime>[].obs;
  var isLoadingTimeslots = false.obs;

  // Getter untuk tampilan
  String get bookingDate =>
      selectedDateTime.value != null
          ? DateFormat('dd/MM/yyyy').format(selectedDateTime.value!)
          : '';

  String get bookingTime =>
      isTimeSelected.value && selectedDateTime.value != null
          ? DateFormat('HH:mm').format(selectedDateTime.value!)
          : '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedMotor.value = Get.arguments as MotorModel;
      debugPrint("📢 Received motor argument: ${selectedMotor.value?.id}");
    }

    // Jangan langsung set tanggal dan waktu - biarkan user pilih dulu
    // selectedDateTime akan di-set saat user memilih tanggal

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
      selectedVariants[service.id] ??= null;
      selectedAddons[service.id] ??= [];
    } else {
      selectedService.removeWhere((s) => s.id == service.id);
      selectedVariants.remove(service.id);
      selectedAddons.remove(service.id);
    }
  }

  void setSelectedVariant(String serviceId, Variant? variant) {
    selectedVariants[serviceId] = variant;
  }

  void toggleAddon(String serviceId, Addon addon, bool isSelected) {
    final currentAddons = List<Addon>.from(selectedAddons[serviceId] ?? []);

    if (isSelected) {
      if (!currentAddons.any((item) => item.id == addon.id)) {
        currentAddons.add(addon);
      }
    } else {
      currentAddons.removeWhere((item) => item.id == addon.id);
    }

    selectedAddons[serviceId] = currentAddons;
  }

  Variant? getSelectedVariant(String serviceId) {
    return selectedVariants[serviceId];
  }

  List<Addon> getSelectedAddons(String serviceId) {
    return selectedAddons[serviceId] ?? [];
  }

  double getServicePrice(ServiceModel service) {
    final variantModifier = selectedVariants[service.id]?.priceModifier ?? 0;
    final addonsTotal = getSelectedAddons(
      service.id,
    ).fold<double>(0, (sum, addon) => sum + addon.price);
    return service.basePrice + variantModifier + addonsTotal;
  }

  /// Filter layanan berdasarkan search query
  List<ServiceModel> filterServices(String query) {
    if (query.isEmpty) {
      return availableServices;
    }

    final lowerQuery = query.toLowerCase();
    return availableServices.where((service) {
      final name = service.name.toLowerCase();
      final description = service.description.toLowerCase();
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  int get totalPrice {
    double total = 0;
    for (var service in selectedService) {
      total += getServicePrice(service);
    }
    return total.round();
  }

  List<Map<String, dynamic>> buildBookingServices() {
    return selectedService.map((service) {
      final selectedVariant = getSelectedVariant(service.id);
      final selectedAddons = getSelectedAddons(service.id);

      return {
        'serviceId': service.id,
        'selectedVariant': selectedVariant?.name,
        'selectedAddons':
            selectedAddons
                .map((addon) => {'addonId': addon.id, 'quantity': 1})
                .toList(),
      };
    }).toList();
  }

  bool isMotorMustBeLeft() {
    final formUI = selectedService;
    if (formUI.isEmpty) return false;

    // Jika ada 1 saja layanan yang isWaitable == false, maka HARUS ditinggal
    for (var service in formUI) {
      if (service.isWaitable == false) return true;
    }
    return false;
  }

  Future<void> submitBooking() async {
    debugPrint("🚀 Submit booking called");
    debugPrint("Selected services: ${selectedService.length}");
    debugPrint("Selected motor: ${selectedMotor.value?.id}");

    if (selectedService.isEmpty) {
      CustomModal.showErrorDialog(
        title: "Informasi",
        message: "Silakan pilih minimal satu layanan",
      );
      return;
    }

    // Validasi tanggal dan waktu booking
    if (selectedDateTime.value == null) {
      CustomModal.showErrorDialog(
        title: "Informasi",
        message: "Silakan pilih tanggal dan waktu booking",
      );
      return;
    }

    // Validasi slot tidak disabled
    if (isTimeSlotDisabled(selectedDateTime.value!)) {
      CustomModal.showErrorDialog(
        title: "Informasi",
        message:
            "Slot waktu yang dipilih tidak tersedia. Silakan pilih slot lain.",
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint("📤 Sending booking request...");

      // Format DateTime ke format yang diinginkan backend
      final bookingDateTime = selectedDateTime.value ?? DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
      final formattedTime = DateFormat('HH:mm').format(bookingDateTime);

      debugPrint("📅 Booking Date: $formattedDate, Time: $formattedTime");

      final bookingServices = buildBookingServices();
      debugPrint("📋 Booking Services: $bookingServices");

      final payload = {
        'motorcycleId': selectedMotor.value?.id,
        'bookingServices': bookingServices,
        'bookingDate': formattedDate,
        'bookingTime': formattedTime,
        'complaint': complaintCtrl.text,
      };
      debugPrint("📤 Payload yang dikirim: $payload");

      final response = await provider.addBooking(payload);

      debugPrint("📥 Response received: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.body?['error'] != null) {
        debugPrint("❌ Backend Error Details: ${response.body['error']}");
      }

      if (response.isOk && response.body != null) {
        CustomSnackbar.success("Sukses", "Booking berhasil dibuat");
        Get.offAllNamed('/dashboard');
      } else {
        CustomModal.showErrorDialog(
          title: "Informasi",
          message: response.body?['message'] ?? 'Gagal membuat booking',
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
      // Set tanggal baru, reset waktu agar user harus pilih ulang
      selectedDateTime.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
      );

      // Reset flag waktu karena tanggal berubah
      isTimeSelected.value = false;

      // Fetch booked times untuk tanggal yang dipilih
      await fetchBookedTimes(picked);
    }
  }

  /// Fetch booked times untuk tanggal tertentu
  Future<void> fetchBookedTimes(DateTime date) async {
    try {
      isLoadingTimeslots.value = true;
      final response = await provider.fetchBookingsByDate(date);

      if (response.isOk && response.body != null) {
        final bookings = response.body['data'] ?? [];
        final times = <DateTime>[];

        // Parse booked times dari response - hanya ambil yang belum dibatalkan
        for (var booking in bookings) {
          // Filter berdasarkan status - skip jika booking dibatalkan
          final status =
              booking['status']?.toString().toLowerCase() ?? 'confirmed';
          if (status == 'dibatalkan' || status == 'pending_cancellation') {
            debugPrint(
              "⏭️  Skipping cancelled booking at ${booking['bookingDate']}",
            );
            continue;
          }

          if (booking['bookingDate'] != null) {
            try {
              final bookedDate = DateTime.parse(booking['bookingDate']);
              int hour = bookedDate.hour;
              int minute = bookedDate.minute;

              // Gunakan bookingTime dari API versi baru (misal "09:00") jika ada
              if (booking['bookingTime'] != null) {
                final timeParts = booking['bookingTime'].toString().split(':');
                if (timeParts.length >= 2) {
                  hour = int.tryParse(timeParts[0]) ?? hour;
                  minute = int.tryParse(timeParts[1]) ?? minute;
                }
              }

              // Gabungkan tanggal dengan jam yang sudah di parse
              final bookedDateTime = DateTime(
                bookedDate.year,
                bookedDate.month,
                bookedDate.day,
                hour,
                minute,
              );
              times.add(bookedDateTime);
            } catch (e) {
              debugPrint("Error parsing booking date: $e");
            }
          }
        }

        bookedTimes.value = times;
        debugPrint(
          "🕐 Booked times for ${DateFormat('dd/MM/yyyy').format(date)}: ${times.length} slots",
        );
      } else {
        bookedTimes.value = [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching booked times: $e");
      bookedTimes.value = [];
    } finally {
      isLoadingTimeslots.value = false;
    }
  }

  /// Get list of available time slots (8 AM - 3 PM)
  List<DateTime> getAvailableTimeSlots() {
    final currentDateTime = selectedDateTime.value ?? DateTime.now();
    final slots = <DateTime>[];

    // Create slots from 8 AM to 3 PM (15:00)
    for (int hour = 8; hour < 15; hour++) {
      final slot = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        hour,
        0,
      );
      slots.add(slot);
    }

    return slots;
  }

  /// Check if a time slot is booked
  bool isTimeSlotBooked(DateTime timeSlot) {
    return bookedTimes.any((bookedTime) {
      return bookedTime.year == timeSlot.year &&
          bookedTime.month == timeSlot.month &&
          bookedTime.day == timeSlot.day &&
          bookedTime.hour == timeSlot.hour;
    });
  }

  /// Check if a time slot is disabled (booked or already passed)
  bool isTimeSlotDisabled(DateTime timeSlot) {
    final now = DateTime.now();
    final isToday =
        timeSlot.year == now.year &&
        timeSlot.month == now.month &&
        timeSlot.day == now.day;

    // Jika hari ini, check apakah slot sudah lewat dari waktu sekarang
    if (isToday && timeSlot.hour <= now.hour) {
      return true;
    }

    // Check apakah sudah ada booking di slot tersebut
    return isTimeSlotBooked(timeSlot);
  }

  // Method untuk memilih waktu dengan custom picker menampilkan slot 8 AM - 3 PM
  Future<void> pickTime(BuildContext context) async {
    // Refresh booked times sebelum menampilkan dialog
    if (selectedDateTime.value != null) {
      await fetchBookedTimes(selectedDateTime.value!);
    }

    final timeSlots = getAvailableTimeSlots();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Jam Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jam Operasional: 08:00 - 15:00',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () =>
                      isLoadingTimeslots.value
                          ? const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : SizedBox(
                            height: 250,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                              itemCount: timeSlots.length,
                              itemBuilder: (context, index) {
                                final timeSlot = timeSlots[index];
                                final isDisabled = isTimeSlotDisabled(timeSlot);
                                final isBooked = isTimeSlotBooked(timeSlot);
                                final isPassed =
                                    timeSlot.hour <= DateTime.now().hour &&
                                    timeSlot.year == DateTime.now().year &&
                                    timeSlot.month == DateTime.now().month &&
                                    timeSlot.day == DateTime.now().day;
                                final isSelected =
                                    selectedDateTime.value?.hour ==
                                    timeSlot.hour;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        isDisabled
                                            ? null
                                            : () {
                                              selectedDateTime.value = timeSlot;
                                              isTimeSelected.value = true;
                                              Navigator.pop(context);
                                            },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isDisabled
                                                ? Colors.grey[300]
                                                : isSelected
                                                ? ColorTheme.primary
                                                : Colors.white,
                                        border: Border.all(
                                          color:
                                              isDisabled
                                                  ? Colors.grey[400]!
                                                  : isSelected
                                                  ? ColorTheme.primary
                                                  : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(timeSlot),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isDisabled
                                                      ? Colors.grey[600]
                                                      : isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isDisabled
                                                ? (isPassed ? 'Lewat' : 'Penuh')
                                                : 'Tersedia',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color:
                                                  isDisabled
                                                      ? Colors.grey[500]
                                                      : isSelected
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
