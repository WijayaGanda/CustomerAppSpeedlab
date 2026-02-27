import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_button.dart';
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
        backgroundColor: Colors.white,
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
                        color: ColorTheme.secondaryColor,
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
                          border: Border.all(color: ColorTheme.secondaryColor),
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
                          border: Border.all(color: ColorTheme.secondaryColor),
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
                                      controller.selectedDateTime.value != null
                                          ? controller.bookingTime
                                          : 'Pilih Waktu',
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

              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableServices.length,
                  itemBuilder: (context, index) {
                    final service = controller.availableServices[index];
                    return Card(
                      elevation: 15,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Obx(() {
                        // Pengecekan status centang dipindah ke DALAM Obx
                        bool isSelected = controller.selectedService.any(
                          (item) => item.id == service.id,
                        );

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

                          value:
                              isSelected, // Sekarang ini akan langsung bereaksi

                          onChanged: (bool? value) {
                            controller.toggleService(service, value ?? false);
                          },

                          activeColor: ColorTheme.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    );
                  },
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
                            foregroundColor: Colors.white,
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
