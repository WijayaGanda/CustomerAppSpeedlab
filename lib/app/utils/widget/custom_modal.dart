import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_theme.dart';

class CustomModal {
  static void showBottomSheet({
    required Widget content,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    EdgeInsets? padding,
  }) {
    Get.bottomSheet(
      Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (title != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
            ],

            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: content,
              ),
            ),
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
    );
  }

  static void showDialog({
    required Widget content,
    String? title,
    bool barrierDismissible = true,
    EdgeInsets? padding,
    double? width,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: width ?? Get.width * 0.9,
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              content,
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showActionSheet({
    required List<ActionSheetItem> actions,
    String? title,
    String? message,
    bool isDismissible = true,
  }) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (title != null || message != null) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
            ],

            ...actions.map((action) => _buildActionItem(action)),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: true,
    );
  }

  static Widget _buildActionItem(ActionSheetItem action) {
    return InkWell(
      onTap: () {
        Get.back();
        action.onPressed?.call();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                color: action.isDestructive ? Colors.red : ColorTheme.primary,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                action.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: action.isDestructive ? Colors.red : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionSheetItem {
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  ActionSheetItem({
    required this.title,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });
}
