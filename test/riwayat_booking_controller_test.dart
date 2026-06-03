import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';
import 'riwayat_booking_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BookingsProvider>(),
  MockSpec<AuthService>(),
  MockSpec<ServiceHistoryProvider>(),
  MockSpec<PaymentProvider>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiwayatBookingController controller;
  late MockBookingsProvider mockProvider;
  late MockAuthService mockAuthService;
  late MockServiceHistoryProvider mockServiceHistoryProvider;
  late MockPaymentProvider mockPaymentProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockBookingsProvider();
    mockAuthService = MockAuthService();
    mockServiceHistoryProvider = MockServiceHistoryProvider();
    mockPaymentProvider = MockPaymentProvider();

    controller = RiwayatBookingController(
      provider: mockProvider,
      authService: mockAuthService,
      serviceHistoryProvider: mockServiceHistoryProvider,
      paymentProvider: mockPaymentProvider,
    );
  });

  group('fetchBookings() Basis Path Testing V(G)=5', () {
    test('Path 1: response ok, bookings kosong', () async {
      when(
        mockProvider.fetchMyBookings(),
      ).thenAnswer((_) async => Response(statusCode: 200, body: {"data": []}));

      await controller.fetchBookings();

      verify(mockProvider.fetchMyBookings()).called(1);
      expect(controller.isLoading.value, false);
      expect(controller.bookings.isEmpty, true);
    });

    test('Path 2: response ok + booking ada', () async {
      when(mockProvider.fetchMyBookings()).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "data": [
              {"id": "1"},
            ],
          },
        ),
      );

      await controller.fetchBookings();

      verify(mockProvider.fetchMyBookings()).called(1);
      // verify(mockProvider.fetchAllPaymentStatus()).called(1);

      expect(controller.isLoading.value, false);
    });
    test('Path 3: service history terpanggil', () async {
      controller.serviceHistory.add(ServiceHistoryModel(id: "10"));

      controller.bookings.add(BookingsModel(id: "1"));

      when(
        mockProvider.fetchMyBookings(),
      ).thenAnswer((_) async => Response(statusCode: 200, body: {"data": []}));

      await controller.fetchBookings();

      verify(mockProvider.fetchMyBookings()).called(1);
      expect(controller.isLoading.value, false);
    });

    test('Path 4: response gagal', () async {
      when(mockProvider.fetchMyBookings()).thenAnswer(
        (_) async => Response(statusCode: 400, body: {"message": "error"}),
      );

      await controller.fetchBookings();

      verify(mockProvider.fetchMyBookings()).called(1);
      expect(controller.isLoading.value, false);
    });

    test('Path 5: exception terjadi', () async {
      when(mockProvider.fetchMyBookings()).thenThrow(Exception("error server"));

      await controller.fetchBookings();

      verify(mockProvider.fetchMyBookings()).called(1);
      expect(controller.isLoading.value, false);
    });
  });
}
