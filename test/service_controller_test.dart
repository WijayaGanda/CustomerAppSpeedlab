import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'package:speedlab_pelanggan/app/modules/service/controllers/service_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'service_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServiceProvider>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ServiceController controller;
  late MockServiceProvider mockProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockServiceProvider();

    controller = ServiceController(provider: mockProvider);
  });

  group('fetchServices() Basis Path Testing V(G)=3', () {
    // =========================
    // PATH 1
    // =========================
    test('Path 1: Berhasil fetch services', () async {
      when(mockProvider.fetchServices()).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "success": true,
            "data": [
              {
                "_id": "1",
                "name": "Ganti Oli",
                "description": "Servis oli",
                "price": 50000,
                "estimatedTime": 30,
              },
            ],
          },
        ),
      );

      await controller.fetchServices();

      verify(mockProvider.fetchServices()).called(1);

      expect(controller.services.isNotEmpty, true);
      expect(controller.isLoading.value, false);
    });

    // =========================
    // PATH 2
    // =========================
    test('Path 2: Response gagal / body null', () async {
      when(
        mockProvider.fetchServices(),
      ).thenAnswer((_) async => Response(statusCode: 400, body: null));

      await controller.fetchServices();

      verify(mockProvider.fetchServices()).called(1);

      expect(controller.services.isEmpty, true);
      expect(controller.isLoading.value, false);
    });

    // =========================
    // PATH 3
    // =========================
    test('Path 3: Exception terjadi', () async {
      when(mockProvider.fetchServices()).thenThrow(Exception("API Error"));

      await controller.fetchServices();

      verify(mockProvider.fetchServices()).called(1);

      expect(controller.isLoading.value, false);
    });
  });
}
