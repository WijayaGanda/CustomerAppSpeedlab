import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/modules/klaim_garansi/controllers/klaim_garansi_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';

import 'klaim_garansi_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WarrantyClaimProvider>(),
  MockSpec<ServiceHistoryProvider>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late KlaimGaransiController controller;
  late MockWarrantyClaimProvider provider;
  late MockServiceHistoryProvider mockServiceHistoryProvider;

  setUp(() {
    provider = MockWarrantyClaimProvider();
    mockServiceHistoryProvider = MockServiceHistoryProvider();

    controller = KlaimGaransiController(
      warrantyProvider: provider,
      provider: mockServiceHistoryProvider,
    );

    CustomModal.isTest = true;
  });

  group('submitWarrantyClaim() Basis Path Testing V(G)=5', () {
    /// PATH 1 - SUCCESS
    test('submitWarrantyClaim success', () async {
      controller.serviceHistory.add(
        ServiceHistoryModel(id: "1", notes: "rusak"),
      );

      controller.complaintController.text = "rusak";

      when(
        provider.submitWarrantyClaim(any),
      ).thenAnswer((_) async => Response(statusCode: 200, body: {}));

      await controller.submitWarrantyClaim();

      verify(provider.submitWarrantyClaim(any)).called(1);
      expect(controller.isLoading.value, false);
    });

    /// PATH 2 - FAILED RESPONSE
    test('submitWarrantyClaim gagal', () async {
      controller.serviceHistory.add(
        ServiceHistoryModel(id: "1", notes: "rusak,"),
      );

      when(
        provider.submitWarrantyClaim(any),
      ).thenAnswer((_) async => Response(statusCode: 400, body: {}));

      await controller.submitWarrantyClaim();

      expect(controller.isLoading.value, false);
    });

    /// PATH 3 - EXCEPTION
    test('submitWarrantyClaim exception', () async {
      controller.serviceHistory.add(
        ServiceHistoryModel(id: "1", notes: "rusak,"),
      );

      when(provider.submitWarrantyClaim(any)).thenThrow(Exception("error"));

      await controller.submitWarrantyClaim();

      expect(controller.isLoading.value, false);
    });
  });
}
