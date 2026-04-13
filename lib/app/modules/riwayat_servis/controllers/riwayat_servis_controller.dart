import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:flutter/material.dart';

class RiwayatServisController extends GetxController {
  final ServiceHistoryProvider provider;

  RiwayatServisController({required this.provider});

  var serviceHistory = <ServiceHistoryModel>[].obs;
  var selectedBooking = Rxn<BookingsModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedBooking.value = Get.arguments as BookingsModel?;

    fetchServiceHistory(selectedBooking.value?.id.toString() ?? '');
  }

  Future<void> fetchServiceHistory(String bookingId) async {
    if (selectedBooking.value == null) return;

    isLoading.value = true;
    try {
      final response = await provider.getServiceHistory(bookingId);
      if (response.isOk) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        if (serviceHistoryResponse.data != null) {
          serviceHistory.value = [serviceHistoryResponse.data!];
        } else {
          serviceHistory.value = [];
        }
        CustomModal.showSuccessDialog(
          title: 'Riwayat Servis Ditemukan',
          message: 'Riwayat servis berhasil ditemukan untuk booking ini.',
        );
      } else if (serviceHistory.first.status?.toLowerCase() == 'selesai') {
        // disableForm();
      } else {
        CustomModal.showErrorDialog(
          title: 'Riwayat Servis Kosong',
          message: 'Silahkan tambahkan riwayat servis untuk booking ini.',
        );
      }
    } catch (e) {
      debugPrint('Error fetching service history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
