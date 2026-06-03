import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'package:speedlab_pelanggan/app/modules/add_motor/controllers/add_motor_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'add_motor_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MotorcyclesProvider>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AddMotorController controller;
  late MockMotorcyclesProvider mockProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockMotorcyclesProvider();
    mockProvider = MockMotorcyclesProvider();

    controller = AddMotorController(provider: mockProvider);
  });

  tearDown(() {
    Get.reset();
  });

  group('addMotor() Basis Path Testing V(G)=4', () {
    test('Path 1: Validasi gagal karena field kosong', () async {
      controller.brand.text = '';
      controller.model.text = '';
      controller.year.text = '';
      controller.licensePlate.text = '';
      controller.color.text = '';

      await controller.addMotor();

      verifyNever(mockProvider.addMotorCycles(any));
      expect(controller.isLoading.value, false);
    });

    test('Path 2: Berhasil tambah motor', () async {
      controller.brand.text = 'Honda';
      controller.model.text = 'Vario';
      controller.year.text = '2024';
      controller.licensePlate.text = 'L 1234 XX';
      controller.color.text = 'Hitam';

      when(mockProvider.addMotorCycles(any)).thenAnswer(
        (_) async => Response(statusCode: 200, body: {"success": true}),
      );

      await controller.addMotor();

      verify(mockProvider.addMotorCycles(any)).called(1);

      expect(controller.isLoading.value, false);
    });

    test('Path 3: Gagal tambah motor karena response API gagal', () async {
      controller.brand.text = 'Honda';
      controller.model.text = 'Vario';
      controller.year.text = '2024';
      controller.licensePlate.text = 'L 1234 XX';
      controller.color.text = 'Hitam';

      when(mockProvider.addMotorCycles(any)).thenAnswer(
        (_) async => Response(statusCode: 400, body: {"message": "Gagal"}),
      );

      await controller.addMotor();

      verify(mockProvider.addMotorCycles(any)).called(1);

      expect(controller.isLoading.value, false);
    });

    test('Path 4: finally tetap dijalankan saat exception', () async {
      controller.brand.text = 'Honda';
      controller.model.text = 'Vario';
      controller.year.text = '2024';
      controller.licensePlate.text = 'L 1234 XX';
      controller.color.text = 'Hitam';

      when(
        mockProvider.addMotorCycles(any),
      ).thenThrow(Exception('Server Error'));

      expect(() async => await controller.addMotor(), throwsException);

      expect(controller.isLoading.value, false);
    });
  });
}
