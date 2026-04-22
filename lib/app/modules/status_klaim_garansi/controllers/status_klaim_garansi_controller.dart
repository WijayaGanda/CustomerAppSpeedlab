import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';

class StatusKlaimGaransiController extends GetxController {
  final ServiceHistoryProvider provider;
  final WarrantyClaimProvider warrantyProvider;

  StatusKlaimGaransiController({
    required this.provider,
    required this.warrantyProvider,
  });

  var serviceHistory = <ServiceHistoryModel>[].obs;
  var selectedBooking = Rxn<BookingsModel>();
  var isLoading = false.obs;
  var warrantyClaims = <WarrantyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedBooking.value = Get.arguments as BookingsModel?;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchServiceHistory(selectedBooking.value?.id.toString() ?? '');
    await fetchWarrantyClaims();
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
      }
    } catch (e) {
      print('Error fetching service history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWarrantyClaims() async {
    if (selectedBooking.value == null || serviceHistory.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await warrantyProvider.getMyWarrantyClaims();
      if (response.isOk) {
        final warrantyResponse = WarrantyResponse.fromJson(response.body);

        // Filter warranty claims yang sesuai dengan service history saat ini
        final filteredClaims =
            warrantyResponse.data.where((claim) {
              return claim.serviceHistoryId?['_id'] ==
                      serviceHistory.first.id ||
                  claim.serviceHistoryId == serviceHistory.first.id;
            }).toList();

        warrantyClaims.value = filteredClaims;
        debugPrint(
          'Fetched ${filteredClaims.length} warranty claims for this service',
        );
      } else {
        debugPrint('Failed to fetch warranty claims: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching warranty claims: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
