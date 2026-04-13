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
              width: 130, // Lebar proporsional
              height: 145, // Tinggi proporsional
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
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          0.04,
                        ), // Latar netral abu-abu
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 26,
                        color: Colors.black87,
                      ), // Hitam pekat
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 90,
                      height: 3,
                      decoration: BoxDecoration(
                        color: ColorTheme.neonYellow, // Identitas Neon Yellow
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${formatPrice(service.price)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black, // Tegas hitam
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
