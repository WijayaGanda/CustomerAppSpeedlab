import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';

class CustomShowcase extends StatelessWidget {
  final String title;
  final String description;
  final bool isLast;

  const CustomShowcase({
    super.key,
    required this.title,
    required this.description,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Sesuaikan lebar tooltip
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Skip (Lewati)
              TextButton(
                onPressed: () {
                  // Memberhentikan paksa seluruh tutorial
                  ShowcaseView.getNamed('tutorial_home').dismiss();
                },
                child: Text(
                  "Lewati",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),

              // Tombol Next (Lanjut) / Selesai
              ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    ShowcaseView.getNamed('tutorial_home').dismiss();
                  } else {
                    // Melanjutkan ke target selanjutnya
                    ShowcaseView.getNamed('tutorial_home').next();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  isLast ? "Selesai" : "Lanjut",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
