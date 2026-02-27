import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/theme/color_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool isObscure; // Untuk password
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final IconData? iconLabel;
  final String? label;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.prefixIcon,
    this.isObscure = true,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.iconLabel,
    this.label,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              // Icon(
              //   iconLabel,
              //   color: Color.fromARGB(255, 17, 189, 14),
              //   size: 20,
              // ),
              SizedBox(width: 8),
              Text(
                label ?? labelText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF333333)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: ColorTheme.secondaryColor,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 17, 189, 14),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
