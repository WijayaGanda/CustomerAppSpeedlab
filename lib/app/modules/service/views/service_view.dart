import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_menu_info.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';

import '../controllers/service_controller.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Layanan Servis',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchServices(),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListView.builder(
                    itemBuilder: (context, index) {
                      final service = controller.services[index];
                      return CustomMenuInfo(
                        icon: Icons.build,
                        label: service.name,
                        iconArrow: Icons.keyboard_arrow_down_sharp,
                        subtitle:
                            service.isActive ? "Tersedia" : "Tidak Tersedia",
                        onTap: () {
                          CustomModal.showBottomSheet(
                            height: Get.height * 0.7,
                            title: service.name,
                            content: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    "Deskripsi",
                                    service.description,
                                  ),
                                  _buildDetailRow(
                                    "Harga",
                                    "Rp ${service.price}",
                                  ),
                                  _buildDetailRow(
                                    "Status Layanan",
                                    service.isActive
                                        ? "Tersedia"
                                        : "Tidak Tersedia",
                                  ),
                                  _buildDetailRow(
                                    "Estimasi Durasi",
                                    "${service.estimatedDuration} menit",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: controller.services.length,
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Text(
          ': ',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    ),
  );
}
