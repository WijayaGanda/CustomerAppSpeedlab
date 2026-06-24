import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';

String formatPrice(dynamic price) {
  final intPrice = (price % 1 == 0 ? price.toInt() : price).toString();
  final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return intPrice.replaceAllMapped(regex, (match) => '${match[1]}.');
}

class ServiceCatalogWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ServiceCatalogWidget({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Row(
      children: List.generate(c.service.length > 10 ? 6 : c.service.length, (
        index,
      ) {
        final service = c.service[index];
        final bool isActive = service.isActive ?? false;
        return Padding(
          padding: EdgeInsets.only(
            right:
                index < (c.service.length > 10 ? 5 : c.service.length - 1)
                    ? 12
                    : 0,
          ),
          child: GestureDetector(
            onTap: () {
              CustomModal.showBottomSheet(
                height: Get.height * 0.8,
                title: service.name ?? "Detail Layanan",
                content: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          "Deskripsi",
                          service.description ?? "-",
                        ),
                        _buildDetailRow(
                          "Harga",
                          "Rp ${formatPrice(service.basePrice ?? 0)}",
                        ),
                        _buildDetailRow(
                          "Status",
                          isActive ? "Tersedia" : "Tidak Tersedia",
                          isActive,
                        ),
                        _buildDetailRow(
                          "Durasi",
                          "${service.estimatedDuration ?? 0} Menit",
                        ),
                        const SizedBox(height: 24),

                        // ========== VARIANTS SECTION ==========
                        if (service.variants != null &&
                            service.variants!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Variants',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...service.variants!.map((variant) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          variant.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Modifier: Rp ${formatPrice(variant.priceModifier)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        if (variant.description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              variant.description,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // ========== ADDONS SECTION ==========
                        if (service.availableAddons != null &&
                            service.availableAddons!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Addons',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...service.availableAddons!.map((addon) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                addon.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    addon.type == 'OPTIONAL'
                                                        ? Colors.orange
                                                            .withOpacity(0.2)
                                                        : Colors.red
                                                            .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                addon.type,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      addon.type == 'OPTIONAL'
                                                          ? Colors.orange[700]
                                                          : Colors.red[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Harga: Rp ${formatPrice(addon.price)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        if (addon.description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              addon.description,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: 130,
              height: 140, // Disamakan dengan batas tinggi ListView parent
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
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, // Diperkecil agar lebih aman
                  vertical: 10, // Diperkecil dari 12 ke 10
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10), // Diperkecil dari 12
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 24, // Diperkecil dari 26 ke 24
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6), // Diperkecil spasi atasnya
                    // Spacer diganti dengan Expanded pada Text
                    // agar otomatis menyesuaikan sisa ruang kosong tanpa error
                    Expanded(
                      child: Center(
                        child: Text(
                          service.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11, // Disusutkan sedikit ke 11
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),
                    Container(
                      width: 80, // Sedikit diperpendek
                      height: 3,
                      decoration: BoxDecoration(
                        color: ColorTheme.neonYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4), // Diperkecil dari 6
                    Text(
                      'Detail Layanan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11, // Disusutkan ke 11
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

Widget _buildDetailRow(String label, String value, [bool? isActive]) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ),
        Text(
          ': ',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              isActive != null
                  ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  )
                  : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3142),
                      height: 1.4,
                    ),
                  ),
        ),
      ],
    ),
  );
}
