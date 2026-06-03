import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'payment_dp_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PaymentProvider>(),
  MockSpec<BookingsProvider>(),
  MockSpec<ServiceHistoryProvider>(),
  MockSpec<AuthService>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiwayatBookingController controller;
  late MockPaymentProvider mockPaymentProvider;
  late MockBookingsProvider mockBookingsProvider;
  late MockServiceHistoryProvider mockServiceHistoryProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockPaymentProvider = MockPaymentProvider();
    mockBookingsProvider = MockBookingsProvider();
    mockServiceHistoryProvider = MockServiceHistoryProvider();
    mockAuthService = MockAuthService();

    controller = RiwayatBookingController(
      paymentProvider: mockPaymentProvider,
      provider: mockBookingsProvider,
      serviceHistoryProvider: mockServiceHistoryProvider,
      authService: mockAuthService,
    );
  });

  group('makeDownPaymentAPI() Basis Path Testing V(G)=7', () {
    // PATH 1
    test('Path 1: id null / kosong', () async {
      await controller.makeDownPaymentAPI(null);

      verifyNever(mockPaymentProvider.createPayment(any));

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 2
    test('Path 2: response sukses mobile + result true', () async {
      when(mockPaymentProvider.createPayment(any)).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {'success': true, 'redirect_url': 'https://midtrans.com'},
        ),
      );

      await controller.makeDownPaymentAPI('1');

      verify(mockPaymentProvider.createPayment('1')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 3
    test('Path 3: response sukses mobile + result false', () async {
      when(mockPaymentProvider.createPayment(any)).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {'success': true, 'redirect_url': 'https://midtrans.com'},
        ),
      );

      await controller.makeDownPaymentAPI('2');

      verify(mockPaymentProvider.createPayment('2')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 4
    test('Path 4: response gagal', () async {
      when(mockPaymentProvider.createPayment(any)).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          body: {'success': false, 'message': 'Gagal pembayaran'},
        ),
      );

      await controller.makeDownPaymentAPI('3');

      verify(mockPaymentProvider.createPayment('3')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 5
    test('Path 5: exception terjadi', () async {
      when(
        mockPaymentProvider.createPayment(any),
      ).thenThrow(Exception('API Error'));

      await controller.makeDownPaymentAPI('4');

      verify(mockPaymentProvider.createPayment('4')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 6
    test('Path 6: response sukses tetapi success false', () async {
      when(mockPaymentProvider.createPayment(any)).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {'success': false, 'message': 'Payment gagal'},
        ),
      );

      await controller.makeDownPaymentAPI('5');

      verify(mockPaymentProvider.createPayment('5')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });

    // PATH 7
    test('Path 7: response sukses tetapi body null', () async {
      when(
        mockPaymentProvider.createPayment(any),
      ).thenAnswer((_) async => Response(statusCode: 200, body: null));

      await controller.makeDownPaymentAPI('6');

      verify(mockPaymentProvider.createPayment('6')).called(1);

      expect(controller.isProcessingPayment.value, false);
    });
  });
}
