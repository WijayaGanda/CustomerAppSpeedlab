import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/modules/status_klaim_garansi/controllers/status_klaim_garansi_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';

import 'status_klaim_garansi_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WarrantyClaimProvider>(),
  MockSpec<ServiceHistoryProvider>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late StatusKlaimGaransiController controller;
  late MockWarrantyClaimProvider provider;
  late MockServiceHistoryProvider mockServiceHistoryProvider;

  setUp(() {
    provider = MockWarrantyClaimProvider();
    mockServiceHistoryProvider = MockServiceHistoryProvider();

    controller = StatusKlaimGaransiController(
      warrantyProvider: provider,
      provider: mockServiceHistoryProvider,
    );

    CustomModal.isTest = true;
  });

  group('fetchWarrantyClaims() Basis Path Testing V(G)=4', () {
    /// PATH 1 - EARLY RETURN
    test('fetchWarrantyClaims berhasil', () async {
      controller.selectedBooking.value = null;
      controller.serviceHistory.clear();

      await controller.fetchWarrantyClaims();

      expect(controller.isLoading.value, false);
    });

    /// PATH 2 - SUCCESS + FILTER DATA
    test('fetchWarrantyClaims success filter', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");

      controller.serviceHistory.add(ServiceHistoryModel(id: "1"));

      when(provider.getMyWarrantyClaims()).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "success": true,
            "data": [
              {
                "serviceHistoryId": {"_id": "1"},
              },
            ],
          },
        ),
      );

      await controller.fetchWarrantyClaims();

      expect(controller.warrantyClaims.isNotEmpty, true);
    });

    /// PATH 3 - RESPONSE FAIL
    test('fetchWarrantyClaims gagal response', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");
      controller.serviceHistory.add(ServiceHistoryModel(id: "1"));

      when(
        provider.getMyWarrantyClaims(),
      ).thenAnswer((_) async => Response(statusCode: 400, body: {}));

      await controller.fetchWarrantyClaims();

      expect(controller.isLoading.value, false);
    });

    /// PATH 4 - EXCEPTION
    test('fetchWarrantyClaims exception', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");
      controller.serviceHistory.add(ServiceHistoryModel(id: "1"));

      when(provider.getMyWarrantyClaims()).thenThrow(Exception("error"));

      await controller.fetchWarrantyClaims();

      expect(controller.isLoading.value, false);
    });
  });
}
