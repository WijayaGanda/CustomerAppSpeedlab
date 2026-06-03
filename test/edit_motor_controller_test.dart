import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';

import 'package:speedlab_pelanggan/app/modules/edit_motor/controllers/edit_motor_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'edit_motor_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MotorcyclesProvider>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EditMotorController controller;
  late MockMotorcyclesProvider mockProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockMotorcyclesProvider();

    // register provider ke GetX
    // Get.put<MotorcyclesProvider>(mockProvider);

    controller = EditMotorController(provider: mockProvider);

    controller.onInit();
    controller.motor.value = MotorModel(
      id: "1",
      brand: "Honda",
      model: "Vario",
      year: 2024,
      licensePlate: "L1234XX",
      color: "Hitam",
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('updateMotor() Basis Path Testing V(G)=4', () {
    test('Path 1: Validasi gagal karena field kosong', () async {
      controller.brandCtrl.text = '';
      controller.modelCtrl.text = '';
      controller.yearCtrl.text = '';
      controller.licensePlateCtrl.text = '';
      controller.colorCtrl.text = '';

      await controller.updateMotor("1");

      verifyNever(mockProvider.updateMotorcycle(any, any));
      expect(controller.isLoading.value, false);
    });

    test('Path 2: Berhasil update motor', () async {
      controller.brandCtrl.text = 'Honda';
      controller.modelCtrl.text = 'Vario';
      controller.yearCtrl.text = '2024';
      controller.licensePlateCtrl.text = 'L1234AA';
      controller.colorCtrl.text = 'Hitam';

      when(mockProvider.updateMotorcycle(any, any)).thenAnswer(
        (_) async => Response(statusCode: 200, body: {'message': 'Success'}),
      );

      await controller.updateMotor("1");

      verify(mockProvider.updateMotorcycle(any, any)).called(1);
      expect(controller.isLoading.value, false);
    });

    test('Path 3: Gagal update motor karena response API gagal', () async {
      controller.brandCtrl.text = 'Honda';
      controller.modelCtrl.text = 'Vario';
      controller.yearCtrl.text = '2024';
      controller.licensePlateCtrl.text = 'L1234AA';
      controller.colorCtrl.text = 'Hitam';

      when(mockProvider.updateMotorcycle(any, any)).thenAnswer(
        (_) async =>
            Response(statusCode: 400, body: {'message': 'Gagal update'}),
      );

      await controller.updateMotor("1");

      verify(mockProvider.updateMotorcycle(any, any)).called(1);
      expect(controller.isLoading.value, false);
    });

    test('Path 4: finally tetap dijalankan saat exception', () async {
      controller.brandCtrl.text = 'Honda';
      controller.modelCtrl.text = 'Vario';
      controller.yearCtrl.text = '2024';
      controller.licensePlateCtrl.text = 'L1234AA';
      controller.colorCtrl.text = 'Hitam';

      when(
        mockProvider.updateMotorcycle(any, any),
      ).thenThrow(Exception('API Error'));

      await controller.updateMotor("1");

      verify(mockProvider.updateMotorcycle(any, any)).called(1);

      // memastikan finally tetap dijalankan
      expect(controller.isLoading.value, false);
    });
  });
}
