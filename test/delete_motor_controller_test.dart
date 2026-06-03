import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// import 'package:get/get_connect/http/src/response/response.dart';

// import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/modules/detail_motor/controllers/detail_motor_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

import 'delete_motor_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MotorcyclesProvider>()])
void main() {
  late DetailMotorController controller;
  late MockMotorcyclesProvider mockProvider;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockProvider = MockMotorcyclesProvider();

    controller = DetailMotorController(motorcyclesProvider: mockProvider);
  });

  group('deleteMotor() Basis Path Testing V(G)=3', () {
    // =========================
    // PATH 1
    // =========================
    test('Path 1: Berhasil hapus motor', () async {
      when(mockProvider.deleteMotorcycle('1')).thenAnswer(
        (_) async => Response(statusCode: 200, body: {"message": "Berhasil"}),
      );

      await controller.deleteMotor('1');

      verify(mockProvider.deleteMotorcycle('1')).called(1);

      expect(controller.isLoading.value, false);
    });

    // =========================
    // PATH 2
    // =========================
    test('Path 2: Response API gagal', () async {
      when(mockProvider.deleteMotorcycle('1')).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          body: {"message": "Gagal menghapus data"},
        ),
      );

      await controller.deleteMotor('1');

      verify(mockProvider.deleteMotorcycle('1')).called(1);

      expect(controller.isLoading.value, false);
    });

    // =========================
    // PATH 3
    // =========================
    test('Path 3: Exception terjadi', () async {
      when(
        mockProvider.deleteMotorcycle('1'),
      ).thenThrow(Exception("API Error"));

      await controller.deleteMotor('1');

      verify(mockProvider.deleteMotorcycle('1')).called(1);

      expect(controller.isLoading.value, false);
    });
  });
}
