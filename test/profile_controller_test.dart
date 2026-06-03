import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'profile_controller_test.mocks.dart';

class DummyAuthService extends GetxService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProfileController controller;
  late MockProfileProvider mockProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockProfileProvider();
    mockAuthService = MockAuthService();

    controller = ProfileController(
      provider: mockProvider,
      authservice: mockAuthService,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('fetchProfile() Basis Path Testing V(G)=3', () {
    test('Path 1: Berhasil fetch profile', () async {
      when(mockProvider.fetchProfile()).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "data": {"id": "1", "name": "Wijaya", "email": "wijaya@gmail.com"},
          },
        ),
      );

      await controller.fetchProfile();

      expect(controller.users.value.name, "Wijaya");
      expect(controller.isLoading.value, false);
    });

    test('Path 2: Response gagal / body null', () async {
      when(mockProvider.fetchProfile()).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          body: {"message": "Gagal mengambil data"},
        ),
      );

      await controller.fetchProfile();

      expect(controller.isLoading.value, false);
    });

    test('Path 3: Exception terjadi', () async {
      when(mockProvider.fetchProfile()).thenThrow(Exception("API Error"));

      await controller.fetchProfile();

      expect(controller.isLoading.value, false);
    });
  });
}
