import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'cancel_booking_controllet_test.mocks.dart';
import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';

@GenerateNiceMocks([
  MockSpec<BookingsProvider>(),
  MockSpec<AuthService>(),
  MockSpec<ServiceHistoryProvider>(),
  MockSpec<PaymentProvider>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  CustomSnackbar.isTesting = true;

  late RiwayatBookingController controller;
  late MockBookingsProvider mockProvider;
  late MockAuthService mockAuthService;
  late MockServiceHistoryProvider mockServiceHistoryProvider;
  late MockPaymentProvider mockPaymentProvider;

  setUp(() {
    Get.testMode = true;

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

  group('cancelBookingAPI() Basis Path Testing V(G)=4', () {
    // PATH 1
    test('Path 1: cancel booking berhasil', () async {
      when(mockProvider.cancelBooking(any)).thenAnswer(
        (_) async => Response(statusCode: 200, body: {'success': true}),
      );

      await controller.cancelBookingAPI('1');

      verify(mockProvider.cancelBooking('1')).called(1);

      expect(controller.isLoading.value, false);
    });

    // PATH 2
    test('Path 2: response gagal', () async {
      when(mockProvider.cancelBooking(any)).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          body: {'message': 'Gagal cancel booking'},
        ),
      );

      await controller.cancelBookingAPI('2');

      verify(mockProvider.cancelBooking('2')).called(1);

      expect(controller.isLoading.value, false);
    });

    // PATH 3
    test('Path 3: exception terjadi', () async {
      when(mockProvider.cancelBooking(any)).thenThrow(Exception('API Error'));

      await controller.cancelBookingAPI('3');

      verify(mockProvider.cancelBooking('3')).called(1);

      expect(controller.isLoading.value, false);
    });
  });
}
