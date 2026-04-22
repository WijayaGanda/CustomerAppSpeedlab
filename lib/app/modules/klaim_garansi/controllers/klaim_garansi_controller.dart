import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:flutter/material.dart';

class KlaimGaransiController extends GetxController {
  final ServiceHistoryProvider provider;
  final WarrantyClaimProvider warrantyProvider;

  KlaimGaransiController({
    required this.provider,
    required this.warrantyProvider,
  });

  var serviceHistory = <ServiceHistoryModel>[].obs;
  var selectedBooking = Rxn<BookingsModel>();
  var isLoading = false.obs;
  var warrantyClaims = <WarrantyModel>[].obs;

  var dateFormat = DateTime.now();

  final TextEditingController complaintController = TextEditingController();

  // Getter untuk mengecek apakah klaim garansi sudah ada
  bool get hasExistingClaim =>
      warrantyClaims.isNotEmpty &&
      warrantyClaims.any(
        (claim) =>
            claim.serviceHistoryId?['_id'] == serviceHistory.first.id ||
            claim.serviceHistoryId == serviceHistory.first.id,
      );

  @override
  void onInit() {
    super.onInit();
    selectedBooking.value = Get.arguments as BookingsModel?;

    fetchServiceHistory(selectedBooking.value?.id.toString() ?? '');
    fetchWarrantyClaims();
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
        if (dateFormat.isAfter(serviceHistoryResponse.data!.warrantyExpiry!)) {
          CustomModal.showErrorDialog(
            title: 'Garansi Kadaluarsa',
            message: 'Garansi untuk servis ini sudah kadaluarsa.',
          );
        }
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

  Future<void> fetchWarrantyClaims() async {
    try {
      final response = await warrantyProvider.getMyWarrantyClaims();
      if (response.isOk) {
        final warrantyResponse = WarrantyResponse.fromJson(response.body);
        warrantyClaims.value = warrantyResponse.data;
        debugPrint('Fetched ${warrantyClaims.length} warranty claims');
      } else {
        debugPrint('Failed to fetch warranty claims: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching warranty claims: $e');
    }
  }

  Future<void> submitWarrantyClaim() async {
    isLoading.value = true;
    try {
      final response = await warrantyProvider.submitWarrantyClaim({
        'serviceHistoryId': serviceHistory.first.id,
        'motorcycleId': serviceHistory.first.motorcycleId,
        'complaint': complaintController.text,
      });
      if (response.isOk) {
        Get.back();
        CustomModal.showSuccessDialog(
          title: 'Klaim Garansi Berhasil',
          message: 'Klaim garansi Anda telah berhasil diajukan.',
        );
      } else {
        CustomModal.showErrorDialog(
          title: 'Klaim Garansi Gagal',
          message:
              'Terjadi kesalahan saat mengajukan klaim garansi. Silakan coba lagi.',
        );
      }
    } catch (e) {
      debugPrint('Error submitting warranty claim: $e');
      CustomModal.showErrorDialog(
        title: 'Klaim Garansi Gagal',
        message:
            'Terjadi kesalahan saat mengajukan klaim garansi. Silakan coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
