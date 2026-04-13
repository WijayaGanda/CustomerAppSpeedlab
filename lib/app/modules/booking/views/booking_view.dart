import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';
// import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

import '../controllers/booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halaman Booking',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // --- KARTU INFO MOTOR YANG DIBOOKING ---
              Obx(() {
                final motor = controller.selectedMotor.value;
                if (motor == null)
                  return const SizedBox(); // Sembunyikan jika null

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
                              motor.licensePlate ?? "Tidak Diketahui",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // --- FORM PILIH TANGGAL DAN WAKTU BOOKING ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pilih Tanggal & Waktu:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Form Pilih Tanggal
                    InkWell(
                      onTap: () => controller.pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ColorTheme.darkBgPrimary),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: ColorTheme.secondaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal Booking",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      controller.selectedDateTime.value != null
                                          ? controller.bookingDate
                                          : 'Pilih Tanggal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: ColorTheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Form Pilih Waktu
                    InkWell(
                      onTap: () => controller.pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ColorTheme.darkBgPrimary),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: ColorTheme.secondaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Waktu Booking",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      controller.bookingTime.isEmpty
                                          ? 'Pilih Waktu'
                                          : controller.bookingTime,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: ColorTheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pilih Layanan:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  CustomModal.showBottomSheetWithSearch(
                    height: Get.height * 0.7,
                    title: "Layanan Yang Tersedia",
                    searchHint: "Cari layanan...",
                    contentBuilder: (searchQuery) {
                      return Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Filter services based on search query
                        final filteredServices = controller.filterServices(
                          searchQuery,
                        );

                        if (filteredServices.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty
                                      ? "Tidak ada layanan tersedia"
                                      : "Tidak ada hasil untuk \"$searchQuery\"",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return Card(
                              elevation: 15,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Obx(() {
                                bool isSelected = controller.selectedService
                                    .any((item) => item.id == service.id);

                                return CheckboxListTile(
                                  title: Text(
                                    service.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    service.description,
                                    style: GoogleFonts.poppins(),
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    controller.toggleService(
                                      service,
                                      value ?? false,
                                    );
                                  },
                                  activeColor: ColorTheme.primary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              }),
                            );
                          },
                        );
                      });
                    },
                  );
                },
                child: Text(
                  "Pilih layanan",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              Obx(() {
                if (controller.selectedService.isEmpty) {
                  // Tampilkan teks info jika belum ada yang dipilih
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "*Belum ada layanan yang dipilih",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                // Tampilkan list card layanan yang sudah dipilih
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Layanan Terpilih:",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Looping data selectedService untuk dibuatkan List
                      ...controller.selectedService.map((service) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorTheme.primary.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .build_circle, // Icon opsional buat pemanis
                                color: ColorTheme.secondaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  service
                                      .name, // Sesuaikan dengan property model kamu
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Tombol untuk hapus layanan langsung dari luar
                              InkWell(
                                onTap: () {
                                  // Memanggil fungsi toggleService untuk membatalkan pilihan
                                  controller.toggleService(service, false);
                                },
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(), // Ubah iterable map menjadi list
                    ],
                  ),
                );
              }),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomTextField(
                  controller: controller.complaintCtrl,
                  labelText: "Keluhan Tambahan (opsional)",
                  iconLabel: Icons.description,
                  prefixIcon: Icons.note,
                  maxLines: 5,
                  isObscure: false,
                  hintText: "Masukkan Keluhan Tambahan",
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Obx(
                  () =>
                      controller.isLoading.value
                          ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : CustomButton(
                            backgroundColor: ColorTheme.secondaryColor,
                            foregroundColor: Colors.black,
                            onPressed: () {
                              debugPrint("🔘 Submit button pressed");
                              controller.submitBooking();
                            },
                            icon: Icons.send,
                            text: "Submit Booking",
                          ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
