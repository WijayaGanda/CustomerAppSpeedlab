import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/modules/add_motor/controllers/add_motor_controller.dart';
import 'package:speedlab_pelanggan/app/modules/add_motor/views/add_motor_view.dart';

class MyHttpOverrides extends HttpOverrides {}

class MockMotorcyclesProvider extends GetConnect
    implements MotorcyclesProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAddMotorController extends GetxController
    implements AddMotorController {
  @override
  final brand = TextEditingController();
  @override
  final model = TextEditingController();
  @override
  final year = TextEditingController();
  @override
  final licensePlate = TextEditingController();
  @override
  final color = TextEditingController();

  @override
  RxBool isLoading = false.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAddMotorController mockAddMotorController;

  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false; // VAKSIN GOOGLE FONTS

    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAddMotorController = MockAddMotorController();
    Get.put<AddMotorController>(mockAddMotorController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderAddMotorView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GetMaterialApp(home: AddMotorView()));
    await tester.pump();
  }

  group('AddMotorView Visual Widget Tests', () {
    testWidgets('1. Memastikan semua elemen UI AddMotorView muncul di layar', (
      WidgetTester tester,
    ) async {
      await renderAddMotorView(tester);

      expect(find.text('Daftar Motor Baru'), findsOneWidget);
      expect(find.text('Tambahkan Motor'), findsOneWidget);

      expect(find.text('Merek Motor'), findsOneWidget);
      expect(find.text('Model Motor'), findsOneWidget);
      expect(find.text('Tahun Motor'), findsOneWidget);
      expect(find.text('Plat Nomor'), findsOneWidget);
      expect(find.text('Warna Motor'), findsOneWidget);

      expect(find.text('Tambah Motor'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('2. Menampilkan loading indicator saat isLoading true', (
      WidgetTester tester,
    ) async {
      mockAddMotorController.isLoading.value = true;
      await renderAddMotorView(tester);

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
