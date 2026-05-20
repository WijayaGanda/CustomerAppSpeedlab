import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';

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
        return Padding(
          padding: EdgeInsets.only(
            right:
                index < (c.service.length > 10 ? 5 : c.service.length - 1)
                    ? 12
                    : 0,
          ),
          child: GestureDetector(
            onTap: () => Get.toNamed('/service-detail', arguments: service),
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
                      'Rp ${formatPrice(service.basePrice)}',
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
