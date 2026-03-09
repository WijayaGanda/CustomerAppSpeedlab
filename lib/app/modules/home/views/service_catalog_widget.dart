import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';

class ServiceCatalogWidget extends StatelessWidget {
  // final Widget buildItem
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const ServiceCatalogWidget({
    super.key,
    // required this.buildItem,
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
                    ? 10
                    : 0,
          ),
          child: GestureDetector(
            onTap: () => Get.toNamed('/service-detail', arguments: service),
            child: Container(
              width: 120,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: ColorTheme.primary, width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 25, color: color),
                    ),
                    SizedBox(height: 8),
                    Text(
                      service.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    Divider(
                      height: 8,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey[300],
                    ),
                    Text(
                      'Rp. ${service.price.toString()}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorTheme.primary,
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
