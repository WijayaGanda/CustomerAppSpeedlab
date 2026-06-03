import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
// import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'home_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MotorcyclesProvider>(),
  MockSpec<ServiceProvider>(),
  MockSpec<DashboardController>(),
  MockSpec<AuthService>(),
])
import 'home_controller_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // await GetStorage.init();
  // late MockAuthProvider mockAuthProvider;
  late MockAuthService mockAuthService;
  late MockMotorcyclesProvider mockMotorProvider;
  late MockServiceProvider mockServiceProvider;
  late MockDashboardController mockDashboardController;
  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockMotorProvider = MockMotorcyclesProvider();
    mockServiceProvider = MockServiceProvider();
    mockDashboardController = MockDashboardController();
    // mockAuthProvider = MockAuthProvider();
    mockAuthService = MockAuthService();

    final dummyCallback = InternalFinalCallback<void>(callback: () {});

    when(mockAuthService.onStart).thenReturn(dummyCallback);

    when(mockAuthService.onDelete).thenReturn(dummyCallback);
    when(mockDashboardController.onStart).thenReturn(dummyCallback);

    when(mockDashboardController.onDelete).thenReturn(dummyCallback);

    Get.put<AuthService>(mockAuthService);
    Get.put<DashboardController>(mockDashboardController);

    controller = HomeController(
      motorProvider: mockMotorProvider,
      serviceProvider: mockServiceProvider,
    );
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================
  // fetchMyMotors() -> VG = 6
  // =========================================================

  group('fetchMyMotors() Basis Path Testing V(G)=6', () {
    // =====================================================
    // PATH 1
    // Success load motor
    // =====================================================
    test('Path 1: Success load motors', () async {
      when(mockMotorProvider.fetchMyMotors()).thenAnswer(
        (_) async =>
            Response(statusCode: 200, body: {'success': true, 'data': []}),
      );

      await controller.fetchMyMotors();

      verify(mockMotorProvider.fetchMyMotors()).called(1);
    });

    // =====================================================
    // PATH 2
    // success false
    // =====================================================
    test('Path 2: Motor response success false', () async {
      when(mockMotorProvider.fetchMyMotors()).thenAnswer(
        (_) async =>
            Response(statusCode: 200, body: {'success': false, 'data': []}),
      );

      await controller.fetchMyMotors();

      verify(mockMotorProvider.fetchMyMotors()).called(1);
    });

    // =====================================================
    // PATH 3
    // response gagal
    // =====================================================
    test('Path 3: Response gagal/body null', () async {
      when(
        mockMotorProvider.fetchMyMotors(),
      ).thenAnswer((_) async => Response(statusCode: 500, body: null));

      await controller.fetchMyMotors();

      verify(mockMotorProvider.fetchMyMotors()).called(1);
    });

    // =====================================================
    // PATH 4
    // retry karena statusCode null
    // =====================================================
    test('Path 4: Retry statusCode null', () async {
      when(
        mockMotorProvider.fetchMyMotors(),
      ).thenAnswer((_) async => Response(statusCode: null, body: null));

      await controller.fetchMyMotors();

      verify(mockMotorProvider.fetchMyMotors()).called(greaterThan(1));
    });

    // =====================================================
    // PATH 5
    // exception retry
    // =====================================================
    test('Path 5: Exception retry', () async {
      when(
        mockMotorProvider.fetchMyMotors(),
      ).thenThrow(Exception('Connection Error'));

      await controller.fetchMyMotors();

      verify(mockMotorProvider.fetchMyMotors()).called(greaterThan(1));
    });

    // =====================================================
    // PATH 6
    // exception final gagal setelah retry
    // =====================================================
    test('Path 6: Exception final gagal setelah retry', () async {
      when(
        mockMotorProvider.fetchMyMotors(),
      ).thenThrow(Exception('Server Down'));

      await controller.fetchMyMotors(retryCount: 3);

      verify(mockMotorProvider.fetchMyMotors()).called(1);
    });
  });

  // =========================================================
  // fetchServiceList() -> VG = 5
  // =========================================================

  group('fetchServiceList() Basis Path Testing V(G)=5', () {
    // =====================================================
    // PATH 1
    // success
    // =====================================================
    test('Path 1: Success fetch services', () async {
      when(mockServiceProvider.fetchServices()).thenAnswer(
        (_) async =>
            Response(statusCode: 200, body: {'success': true, 'data': []}),
      );
      await controller.fetchServiceList();

      verify(mockServiceProvider.fetchServices()).called(1);
    });

    // =====================================================
    // PATH 2
    // response gagal
    // =====================================================
    test('Path 2: Response gagal', () async {
      when(
        mockServiceProvider.fetchServices(),
      ).thenAnswer((_) async => Response(statusCode: 500, body: null));

      await controller.fetchServiceList();

      verify(mockServiceProvider.fetchServices()).called(1);
    });

    // =====================================================
    // PATH 3
    // retry status null
    // =====================================================
    test('Path 3: Retry karena statusCode null', () async {
      when(
        mockServiceProvider.fetchServices(),
      ).thenAnswer((_) async => Response(statusCode: null, body: null));

      await controller.fetchServiceList();

      verify(mockServiceProvider.fetchServices()).called(greaterThan(1));
    });

    // =====================================================
    // PATH 4
    // exception retry
    // =====================================================
    test('Path 4: Exception retry', () async {
      when(mockServiceProvider.fetchServices()).thenThrow(Exception('Timeout'));

      await controller.fetchServiceList();

      verify(mockServiceProvider.fetchServices()).called(greaterThan(1));
    });

    // =====================================================
    // PATH 5
    // exception final
    // =====================================================
    test('Path 5: Exception final gagal', () async {
      when(
        mockServiceProvider.fetchServices(),
      ).thenThrow(Exception('Server Error'));

      await controller.fetchServiceList(retryCount: 3);

      verify(mockServiceProvider.fetchServices()).called(1);
    });
  });
}
