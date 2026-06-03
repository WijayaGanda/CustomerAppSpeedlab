import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';

// import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_servis/controllers/riwayat_servis_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';

import 'riwayat_servis_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServiceHistoryProvider>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late RiwayatServisController controller;
  // late MockBookingsProvider provider;
  late MockServiceHistoryProvider mockServiceHistoryProvider;

  setUp(() {
    // provider = MockBookingsProvider();
    mockServiceHistoryProvider = MockServiceHistoryProvider();

    controller = RiwayatServisController(provider: mockServiceHistoryProvider);

    // MATIKAN UI GETX BIAR GA CRASH
    CustomModal.isTest = true;
  });

  group('fetchServiceHistory() Basis Path Testing V(G)=5', () {
    /// =========================
    /// PATH 1: selectedBooking NULL
    /// =========================
    test('Path 1 - selectedBooking null', () async {
      controller.selectedBooking.value = null;

      await controller.fetchServiceHistory("1");

      expect(controller.isLoading.value, false);
    });

    /// =========================
    /// PATH 2: SUCCESS + DATA ADA
    /// =========================
    test('Path 2 - success + data ada', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");

      when(mockServiceHistoryProvider.getServiceHistory("1")).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "data": {"id": "1"},
          },
        ),
      );

      await controller.fetchServiceHistory("1");

      verify(mockServiceHistoryProvider.getServiceHistory("1")).called(1);
      expect(controller.serviceHistory.isNotEmpty, true);
    });

    /// =========================
    /// PATH 3: SUCCESS + DATA NULL
    /// =========================
    test('Path 3 - success tapi data null', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");

      when(mockServiceHistoryProvider.getServiceHistory("1")).thenAnswer(
        (_) async => Response(statusCode: 200, body: {"data": null}),
      );

      await controller.fetchServiceHistory("1");

      expect(controller.serviceHistory.isEmpty, true);
    });

    /// =========================
    /// PATH 4: RESPONSE GAGAL
    /// =========================
    test('Path 4 - response gagal', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");

      when(
        mockServiceHistoryProvider.getServiceHistory("1"),
      ).thenAnswer((_) async => Response(statusCode: 400, body: {}));

      await controller.fetchServiceHistory("1");

      expect(controller.isLoading.value, false);
    });

    /// =========================
    /// PATH 5: EXCEPTION
    /// =========================
    test('Path 5 - exception', () async {
      controller.selectedBooking.value = BookingsModel(id: "1");

      when(
        mockServiceHistoryProvider.getServiceHistory("1"),
      ).thenThrow(Exception("error"));

      await controller.fetchServiceHistory("1");

      expect(controller.isLoading.value, false);
    });
  });
}
