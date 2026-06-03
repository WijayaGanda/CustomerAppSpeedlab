import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'edit_profile_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileProvider>(), MockSpec<AuthService>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  CustomSnackbar.isTesting = true;

  late EditProfileController controller;
  late MockProfileProvider mockProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockProvider = MockProfileProvider();
    mockAuthService = MockAuthService();

    controller = EditProfileController(
      provider: mockProvider,
      authService: mockAuthService,
    );

    controller.onInit();

    controller.nameCtrl.text = "Wijaya";
    controller.emailCtrl.text = "wijaya@gmail.com";
    controller.phoneCtrl.text = "08123";
    controller.addressCtrl.text = "Surabaya";
  });

  tearDown(() {
    Get.reset();
  });

  group('updateProfile() Basis Path Testing V(G)=5', () {
    // PATH 1
    test('Path 1: Validasi field kosong', () async {
      controller.nameCtrl.text = '';

      await controller.updateProfile();

      expect(controller.isLoading.value, false);

      verifyNever(mockProvider.updateProfile(any));
    });

    // PATH 2
    test('Path 2: Response sukses + ProfileController terdaftar', () async {
      final profileController = Get.put(
        ProfileController(provider: mockProvider, authservice: mockAuthService),
      );

      when(mockProvider.updateProfile(any)).thenAnswer(
        (_) async => Response(statusCode: 200, body: {"success": true}),
      );

      await controller.updateProfile();

      expect(controller.isLoading.value, false);

      verify(mockProvider.updateProfile(any)).called(1);

      expect(profileController.users?.value.name, "Wijaya");
    });

    // PATH 3
    test(
      'Path 3: Response sukses + ProfileController tidak terdaftar',
      () async {
        when(mockProvider.updateProfile(any)).thenAnswer(
          (_) async => Response(statusCode: 200, body: {"success": true}),
        );

        await controller.updateProfile();

        expect(controller.isLoading.value, false);

        verify(mockProvider.updateProfile(any)).called(1);
      },
    );

    // PATH 4
    test('Path 4: Response gagal', () async {
      when(mockProvider.updateProfile(any)).thenAnswer(
        (_) async =>
            Response(statusCode: 400, body: {"message": "Gagal update"}),
      );

      await controller.updateProfile();

      expect(controller.isLoading.value, false);

      verify(mockProvider.updateProfile(any)).called(1);
    });

    // PATH 5
    test('Path 5: Exception terjadi', () async {
      when(mockProvider.updateProfile(any)).thenThrow(Exception("API Error"));

      await controller.updateProfile();

      expect(controller.isLoading.value, false);

      verify(mockProvider.updateProfile(any)).called(1);
    });
  });
}
