import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_modal.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'booking_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BookingsProvider>(),
  MockSpec<AuthService>(),
  MockSpec<ServiceProvider>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BookingController controller;
  late MockBookingsProvider mockProvider;
  late MockAuthService mockAuthService;
  late MockServiceProvider mockServiceProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;
    CustomModal.isTest = true;

    mockProvider = MockBookingsProvider();
    mockAuthService = MockAuthService();
    mockServiceProvider = MockServiceProvider();

    controller = BookingController(
      provider: mockProvider,
      authService: mockAuthService,
      serviceProvider: mockServiceProvider,
    );
  });

  group('submitBooking() Basis Path Testing V(G)=7', () {
    test('Path 1: selectedService kosong', () async {
      controller.selectedService.clear();

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });

    test('Path 2: selectedDateTime null', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Perbaikan Mesin',
        description: 'Perbaikan kerusakan',
        basePrice: 500000,
        estimatedDuration: 120,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perbaikan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );

      controller.selectedService.add(service);
      controller.selectedDateTime.value = null;

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });

    test('Path 3: slot waktu disabled', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Perbaikan Mesin',
        description: 'Perbaikan kerusakan',
        basePrice: 500000,
        estimatedDuration: 120,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perbaikan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );
      controller.selectedService.add(service);

      controller.selectedDateTime.value = DateTime.now();

      final result = controller.isTimeSlotDisabled(
        controller.selectedDateTime.value!,
      );

      expect(result, true);

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });

    test('Path 4: response sukses', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Ganti Oli',
        basePrice: 50000,
        description: 'Ganti oli mobil',
        estimatedDuration: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perawatan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );
      controller.selectedService.add(service);

      controller.selectedDateTime.value = DateTime(2030, 1, 1, 10, 0);

      when(mockProvider.addBooking(any)).thenAnswer(
        (_) async => Response(statusCode: 200, body: {'success': true}),
      );

      await controller.submitBooking();

      expect(controller.isLoading.value, false);

      verify(mockProvider.addBooking(any)).called(1);
    });

    test('Path 5: response gagal', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Ganti Oli',
        basePrice: 50000,
        description: 'Ganti oli mobil',
        estimatedDuration: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perawatan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );
      controller.selectedService.add(service);

      controller.selectedDateTime.value = DateTime(2030, 1, 1, 10, 0);

      when(mockProvider.addBooking(any)).thenAnswer(
        (_) async =>
            Response(statusCode: 400, body: {'message': 'Booking gagal'}),
      );

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });

    test('Path 6: response memiliki error backend', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Ganti Oli',
        basePrice: 50000,
        description: 'Ganti oli mobil',
        estimatedDuration: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perawatan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );
      controller.selectedService.add(service);

      controller.selectedDateTime.value = DateTime(2030, 1, 1, 10, 0);

      when(mockProvider.addBooking(any)).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          body: {'error': 'Validation Error', 'message': 'Booking gagal'},
        ),
      );

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });

    test('Path 7: Exception terjadi', () async {
      final service = ServiceModel(
        id: '1',
        name: 'Ganti Oli',
        basePrice: 50000,
        description: 'Ganti oli mobil',
        estimatedDuration: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perawatan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      );
      controller.selectedService.add(service);

      controller.selectedDateTime.value = DateTime(2030, 1, 1, 10, 0);

      when(mockProvider.addBooking(any)).thenThrow(Exception('API Error'));

      await controller.submitBooking();

      expect(controller.isLoading.value, false);
    });
  });
}
