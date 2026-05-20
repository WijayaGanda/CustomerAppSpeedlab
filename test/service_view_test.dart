import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/modules/service/controllers/service_controller.dart';
import 'package:speedlab_pelanggan/app/modules/service/views/service_view.dart';

// ==================== Mocks ====================
class MockServiceProvider extends GetConnect implements ServiceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockServiceController extends GetxController
    implements ServiceController {
  @override
  RxList<ServiceModel> services = <ServiceModel>[].obs;

  @override
  RxBool isLoading = false.obs;

  @override
  ServiceProvider get provider => MockServiceProvider();

  final List<ServiceModel> sampleServices = [
    ServiceModel(
      id: '1',
      name: 'Servis Rutin',
      description: 'Perawatan berkala',
      basePrice: 150000,
      estimatedDuration: 60,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: 'rutin',
      v: 0,
      availableAddons: [],
      variants: [],
      isWaitable: true,
    ),
    ServiceModel(
      id: '2',
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
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    services.value = sampleServices;
  }

  @override
  Future<void> fetchServices() async {
    services.value = sampleServices;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MyHttpOverrides extends HttpOverrides {}

// ==================== Tests ====================
void main() {
  late MockServiceController mockServiceController;

  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false; // Matikan Google Fonts
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockServiceController = MockServiceController();
    Get.put<ServiceController>(mockServiceController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderServiceView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GetMaterialApp(home: ServiceView()));
    await tester.pump();
  }

  group('ServiceView Visual Widget Tests', () {
    testWidgets('1. Memastikan halaman berhasil di-render (Smoke Test)', (
      WidgetTester tester,
    ) async {
      await renderServiceView(tester);

      // Cek AppBar
      expect(find.text('Layanan Servis'), findsOneWidget);
    });

    testWidgets('2. Menampilkan daftar layanan dari mock data', (
      WidgetTester tester,
    ) async {
      await renderServiceView(tester);

      // Cek apakah data list muncul di layar
      expect(find.text('Servis Rutin'), findsOneWidget);
      expect(find.text('Perbaikan Mesin'), findsOneWidget);
    });

    testWidgets('3. Menampilkan state loading (Skeleton) saat memuat data', (
      WidgetTester tester,
    ) async {
      mockServiceController.isLoading.value = true;
      await renderServiceView(tester);

      // Selama loading, Scaffold tetap harus ter-render
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('4. Menampilkan state kosong jika tidak ada data layanan', (
      WidgetTester tester,
    ) async {
      mockServiceController.services.clear(); // Kosongkan data
      await renderServiceView(tester);

      // Pastikan List kosong tanpa menyebabkan crash
      expect(find.text('Servis Rutin'), findsNothing);
    });
  });
}
