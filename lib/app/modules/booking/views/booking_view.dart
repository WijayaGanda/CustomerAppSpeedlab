import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pilih Layanan:",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        // color: ColorTheme.secondaryColor,
                      ),
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
                              final filteredServices = controller
                                  .filterServices(searchQuery);

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
                                      bool isSelected = controller
                                          .selectedService
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
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

                final currency = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );

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
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ColorTheme.primary.withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Obx(() {
                            final selectedVariant = controller
                                .getSelectedVariant(service.id);
                            final selectedAddons = controller.getSelectedAddons(
                              service.id,
                            );
                            final servicePrice = controller.getServicePrice(
                              service,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.build_circle,
                                      color: ColorTheme.secondaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.name,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            currency.format(servicePrice),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: ColorTheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.toggleService(
                                          service,
                                          false,
                                        );
                                      },
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  service.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (service.variants.isNotEmpty) ...[
                                  Text(
                                    'Pilih Varian',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final variant in service.variants)
                                        ChoiceChip(
                                          label: Text(
                                            '${variant.name} • ${currency.format(service.basePrice + variant.priceModifier)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          selected:
                                              selectedVariant?.name ==
                                              variant.name,
                                          selectedColor: ColorTheme.primary,
                                          backgroundColor: Colors.grey[100],
                                          labelStyle: GoogleFonts.poppins(
                                            color:
                                                selectedVariant?.name ==
                                                        variant.name
                                                    ? Colors.white
                                                    : Colors.black87,
                                            fontSize: 11,
                                          ),
                                          onSelected: (_) {
                                            controller.setSelectedVariant(
                                              service.id,
                                              variant,
                                            );
                                          },
                                        ),
                                      ChoiceChip(
                                        label: Text(
                                          'Tanpa varian',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        selected: selectedVariant == null,
                                        selectedColor: ColorTheme.primary,
                                        backgroundColor: Colors.grey[100],
                                        labelStyle: GoogleFonts.poppins(
                                          color:
                                              selectedVariant == null
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 11,
                                        ),
                                        onSelected: (_) {
                                          controller.setSelectedVariant(
                                            service.id,
                                            null,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (service.availableAddons.isNotEmpty) ...[
                                  Text(
                                    'Tambah Add-on',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        for (
                                          int i = 0;
                                          i < service.availableAddons.length;
                                          i++
                                        )
                                          Column(
                                            children: [
                                              CheckboxListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 2,
                                                    ),
                                                dense: true,
                                                value: selectedAddons.any(
                                                  (addon) =>
                                                      addon.id ==
                                                      service
                                                          .availableAddons[i]
                                                          .id,
                                                ),
                                                onChanged: (value) {
                                                  controller.toggleAddon(
                                                    service.id,
                                                    service.availableAddons[i],
                                                    value ?? false,
                                                  );
                                                },
                                                title: Text(
                                                  service
                                                      .availableAddons[i]
                                                      .name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  '${service.availableAddons[i].type} • ${currency.format(service.availableAddons[i].price)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                activeColor: ColorTheme.primary,
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              ),
                                              if (i !=
                                                  service
                                                          .availableAddons
                                                          .length -
                                                      1)
                                                Divider(
                                                  height: 1,
                                                  color: Colors.grey[200],
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (selectedVariant != null ||
                                    selectedAddons.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorTheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ringkasan Pilihan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          selectedVariant != null
                                              ? 'Varian: ${selectedVariant.name}'
                                              : 'Varian: belum dipilih',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          selectedAddons.isEmpty
                                              ? 'Add-on: tidak ada'
                                              : 'Add-on: ${selectedAddons.map((addon) => addon.name).join(', ')}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        );
                      }).toList(), // Ubah iterable map menjadi list
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
                    Obx(
                      () =>
                          controller.isMotorMustBeLeft()
                              ? Text(
                                "*Karena Anda memilih layanan yang membutuhkan waktu pengerjaan lebih dari 1 hari, maka Anda hanya bisa memilih tanggal booking tanpa waktu spesifik. Kami akan menghubungi Anda untuk konfirmasi waktu pengerjaan lebih lanjut.",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                              : InkWell(
                                onTap: () => controller.pickTime(context),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: ColorTheme.darkBgPrimary,
                                    ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                    ),
                  ],
                ),
              ),

              Obx(() {
                if (controller.selectedService.isEmpty) {
                  return const SizedBox.shrink();
                }

                final currency = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 6,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorTheme.primary.withValues(alpha: 0.12),
                          ColorTheme.secondaryColor.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ColorTheme.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: ColorTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimasi Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                currency.format(controller.totalPrice),
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
                            text: "Booking",
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
