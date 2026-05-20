import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/modules/edit_motor/controllers/edit_motor_controller.dart';
import 'package:speedlab_pelanggan/app/modules/edit_motor/views/edit_motor_view.dart';

// ==================== Mock Providers ====================
class MockMotorcyclesProvider extends GetConnect
    implements MotorcyclesProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Edit Motor Controller ====================
class MockEditMotorController extends GetxController
    implements EditMotorController {
  @override
  final motor = Rxn<MotorModel>();

  @override
  final isLoading = false.obs;

  @override
  late TextEditingController brandCtrl;
  @override
  late TextEditingController modelCtrl;
  @override
  late TextEditingController yearCtrl;
  @override
  late TextEditingController licensePlateCtrl;
  @override
  late TextEditingController colorCtrl;

  @override
  MotorcyclesProvider get provider => MockMotorcyclesProvider();

  @override
  void onInit() {
    super.onInit();
    motor.value = MotorModel(
      id: '1',
      brand: 'Honda',
      model: 'Vario 150',
      licensePlate: 'B 1234 XYZ',
      year: 2022,
      color: 'Hitam Doff',
    );
    brandCtrl = TextEditingController(text: 'Honda');
    modelCtrl = TextEditingController(text: 'Vario 150');
    yearCtrl = TextEditingController(text: '2022');
    licensePlateCtrl = TextEditingController(text: 'B 1234 XYZ');
    colorCtrl = TextEditingController(text: 'Hitam Doff');
  }

  @override
  Future<void> updateMotor(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockEditMotorController mockEditMotorController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Buka akses internet jaga-jaga ada network image, tapi matikan Google Fonts fetching
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockEditMotorController = MockEditMotorController();
    mockEditMotorController.onInit();
    Get.put<EditMotorController>(mockEditMotorController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderEditMotorView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(const GetMaterialApp(home: EditMotorView()));
      await tester.pump();
    });
  }

  group('EditMotorView Widget Tests', () {
    testWidgets('1. Smoke test - page renders', (WidgetTester tester) async {
      await renderEditMotorView(tester);
      expect(find.byType(EditMotorView), findsOneWidget);
    });

    testWidgets('2. AppBar displays correct titles', (
      WidgetTester tester,
    ) async {
      await renderEditMotorView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Edit Motor'), findsOneWidget);
    });

    testWidgets('3. CustomHeader displays correctly', (
      WidgetTester tester,
    ) async {
      await renderEditMotorView(tester);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Ubah Data Motor'), findsOneWidget);
      expect(find.text('Perbarui informasi motor Anda'), findsOneWidget);
    });

    testWidgets('4. All form fields display correctly', (
      WidgetTester tester,
    ) async {
      await renderEditMotorView(tester);
      expect(find.text('Merek'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Tahun'), findsOneWidget);
      expect(find.text('Plat Nomor'), findsOneWidget);
      expect(find.text('Warna'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('5. Save button displays correctly', (
      WidgetTester tester,
    ) async {
      await renderEditMotorView(tester);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('6. Scaffold renders correctly', (WidgetTester tester) async {
      await renderEditMotorView(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
